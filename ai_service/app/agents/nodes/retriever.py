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

    query_vec = embed_sync(spec.to_query_text())
    original_radius = settings.default_radius_km
    quality_threshold = settings.default_quality_threshold

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
