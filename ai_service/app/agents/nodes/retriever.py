import logging

from langchain_core.messages import AIMessage

from app.agents.state import InventoryState, ProductSpec
from app.core.config import get_settings
from app.services.embedding_service import embed_sync
from app.services.ranking_service import blend_and_rank
from app.services.vector_store import search as vector_search

logger = logging.getLogger(__name__)

_RELAX_RADIUS_FACTOR = 3
_RELAX_PRICE_MARGIN = 0.2
_RELAX_QUALITY_TIER = 0.2

_SIZE_WORD_MAP = {
    "s": "S", "sm": "S", "small": "S",
    "m": "M", "md": "M", "med": "M", "medium": "M",
    "l": "L", "lg": "L", "large": "L",
    "xl": "XL", "xxl": "XXL",
    "one size": "One Size", "onesize": "One Size", "free size": "One Size",
}

_VAGUE_ANSWER_TOKENS = {
    "any", "anything", "whatever", "don't care", "dont care", "no preference",
    "doesn't matter", "does not matter", "i don't know", "i dunno", "no",
}


def _canonical_attribute_value(value: str, options: list[str]) -> str:
    """Map a free-form user answer onto one of the offered canonical options.

    Falls back to the raw value when no offered option matches, so the filter
    still applies verbatim for values that aren't standard size words.
    """
    v = " ".join(value.strip().lower().split())
    for option in options:
        if " ".join(option.strip().lower().split()) == v:
            return option
    if v in _SIZE_WORD_MAP:
        return _SIZE_WORD_MAP[v]
    return value


def _is_vague(value: str) -> bool:
    return " ".join(value.strip().lower().split()) in _VAGUE_ANSWER_TOKENS


def _attribute_filters(
    required_attributes: dict[str, str], candidates: list[dict]
) -> list[tuple[str, str]]:
    """Build hard attribute filters for every committed answer.

    A filter is only applied when the answer maps onto a real catalog option;
    vague answers ("any", "don't care") and values that don't exist in the
    catalog are skipped so they never empty the result set.
    """
    valid: dict[str, set[str]] = {}
    for c in candidates:
        attrs = (c.get("payload") or {}).get("attributes") or {}
        for key, value in attrs.items():
            valid.setdefault(str(key), set()).add(str(value))

    filters: list[tuple[str, str]] = []
    for key, value in (required_attributes or {}).items():
        if not value or _is_vague(str(value)):
            continue
        options = sorted(valid.get(key, set()))
        canonical = _canonical_attribute_value(str(value), options)
        if canonical in valid.get(key, set()):
            filters.append((key, canonical))
    return filters


def retriever_node(state: InventoryState) -> dict:
    spec = ProductSpec.model_validate(state["spec"])
    location = state.get("customer_location")
    rejected_ids = state.get("rejected_ids", [])
    weights = state.get("rank_weights", {"sim": 1.0, "quality": 0.7, "distance": 0.5})
    settings = get_settings()

    if location is None:
        return {
            "messages": [AIMessage(
                content="To find products near you, I need your location. Could you provide your city or coordinates?"
            )],
            "turn_status": "ask",
        }

    lat, lon = location[0], location[1]
    if not (-90.0 <= lat <= 90.0 and -180.0 <= lon <= 180.0):
        return {
            "messages": [AIMessage(
                content=(
                    f"Your coordinates ({lat:.2f}, {lon:.2f}) look invalid. "
                    "Latitude must be between -90 and 90, longitude between -180 and 180. "
                    "Could you check them or provide your city instead?"
                )
            )],
            "turn_status": "ask",
        }

    query_vec = embed_sync(spec.to_query_text())
    original_radius = settings.default_radius_km
    quality_threshold = settings.default_quality_threshold

    attribute_filters = _attribute_filters(
        spec.required_attributes, state.get("resolved_candidates", [])
    )

    def search_with(radius_km: float, price_min: float | None, price_max: float | None, quality_min: float) -> list[dict]:
        return vector_search(
            query_vec,
            category=spec.category,
            price_min=price_min,
            price_max=price_max,
            geo_center=location,
            geo_radius_km=radius_km,
            quality_min=quality_min,
            excluded_ids=rejected_ids if rejected_ids else None,
            attributes=attribute_filters if attribute_filters else None,
            limit=20,
        )

    candidates = search_with(original_radius, spec.price_min, spec.price_max, quality_threshold)
    relaxed_constraints: list[str] = []

    if not candidates:
        relaxed_radius = original_radius * _RELAX_RADIUS_FACTOR
        candidates = search_with(relaxed_radius, spec.price_min, spec.price_max, quality_threshold)
        if candidates:
            relaxed_constraints.append(f"search radius widened to {relaxed_radius} km")

    if not candidates:
        orig_min = spec.price_min
        orig_max = spec.price_max
        relaxed_min = orig_min * (1 - _RELAX_PRICE_MARGIN) if orig_min is not None else None
        relaxed_max = orig_max * (1 + _RELAX_PRICE_MARGIN) if orig_max is not None else None
        relaxed_radius = original_radius * _RELAX_RADIUS_FACTOR
        candidates = search_with(relaxed_radius, relaxed_min, relaxed_max, quality_threshold)
        if candidates:
            parts = []
            if orig_min is not None:
                parts.append(f"price floor lowered to ${relaxed_min:.2f}")
            if orig_max is not None:
                parts.append(f"price ceiling raised to ${relaxed_max:.2f}")
            relaxed_constraints.append(f"budget range expanded ({'; '.join(parts)})")

    if not candidates:
        relaxed_quality = quality_threshold - _RELAX_QUALITY_TIER
        relaxed_radius = original_radius * _RELAX_RADIUS_FACTOR
        orig_min = spec.price_min
        orig_max = spec.price_max
        relaxed_min = orig_min * (1 - _RELAX_PRICE_MARGIN) if orig_min is not None else None
        relaxed_max = orig_max * (1 + _RELAX_PRICE_MARGIN) if orig_max is not None else None
        candidates = search_with(relaxed_radius, relaxed_min, relaxed_max, relaxed_quality)
        if candidates:
            relaxed_constraints.append("quality threshold lowered")

    if not candidates:
        candidates = vector_search(
            query_vec,
            category=spec.category,
            price_min=relaxed_min,
            price_max=relaxed_max,
            quality_min=relaxed_quality,
            excluded_ids=rejected_ids if rejected_ids else None,
            attributes=attribute_filters if attribute_filters else None,
            limit=20,
        )
        if candidates:
            relaxed_constraints.append("search radius limit removed (showing closest available matches)")

    if not candidates:
        msg = "I couldn't find any products matching your requirements."
        if relaxed_constraints:
            msg += f" Even after {', '.join(relaxed_constraints)}, no results were found."
        return {
            "messages": [AIMessage(content=msg)],
            "ranked_results": [],
            "candidates": [],
            "turn_status": "done",
        }

    ranked = blend_and_rank(candidates, weights, location, original_radius)

    lines = [f"Here are the top {len(ranked)} results:"]
    if relaxed_constraints:
        lines.append(f"(Note: {', '.join(relaxed_constraints)})")
    for i, r in enumerate(ranked, 1):
        price_str = f"${r.price:.2f}" if r.price else "N/A"
        dist_str = f"{r.distance_km:.1f} km" if r.distance_km else "N/A"
        lines.append(f"{i}. Product {r.product_id} — {price_str}, quality {r.quality_score:.2f}, {dist_str}")

    return {
        "messages": [AIMessage(content="\n".join(lines))],
        "ranked_results": ranked,
        "candidates": candidates,
        "turn_status": "done",
    }
