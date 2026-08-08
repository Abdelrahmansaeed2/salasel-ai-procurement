import logging

from langchain_core.messages import HumanMessage
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder

from app.agents.order.state import ExtractedOrders, OrderLine, OrderState, ProductMatch
from app.core.config import get_settings
from app.core.llm import get_llm
from app.schemas.order import OrderResponse, OrderSplit
from app.services.embedding_service import embed_sync
from app.services.ranking_service import blend_and_rank
from app.services.vector_store import search as vector_search

logger = logging.getLogger(__name__)

_DEFAULT_WEIGHTS = {"sim": 1.0, "quality": 0.7, "distance": 0.5}

EXTRACT_SYSTEM_PROMPT = (
    "You are an order-drafting assistant. Based on a transcript of a customer "
    "requesting products, extract every product they want to buy and output a JSON "
    "object with a \"products\" array.\n"
    "For each product capture:\n"
    "- product_name: the item being purchased (required)\n"
    "- quantity: how many units they asked for, or null if not stated\n"
    "- category: if clear from context, else null\n"
    "- requested_attributes: key/value pairs the customer specified (size, color, packaging, units, etc.)\n"
    "- price_bound_min / price_bound_max: any price range they stated, else null\n"
    "Rules:\n"
    "- Never invent a value the customer did not state; leave unknown fields null.\n"
    "- If the same product appears with different quantities/specs, emit one entry each.\n"
    "- Always return valid JSON. Never respond conversationally."
)


def _build_extract_chain():
    llm = get_llm(role="conversation")
    try:
        structured = llm.with_structured_output(ExtractedOrders, method="json_mode")  # type: ignore[call-overload]
    except TypeError:
        structured = llm.with_structured_output(ExtractedOrders)  # type: ignore[call-overload]
    prompt = ChatPromptTemplate.from_messages([
        ("system", EXTRACT_SYSTEM_PROMPT),
        MessagesPlaceholder(variable_name="messages"),
    ])
    return prompt | structured


def extract_products_node(state: OrderState) -> dict:
    chain = _build_extract_chain()
    result = ExtractedOrders.model_validate(
        chain.invoke({"messages": [HumanMessage(content=state["transcript"])]})
    )
    errors: list[str] = []
    if not result.products:
        errors.append("No products were extracted from the transcript")
    logger.info("order extract products=%d", len(result.products))
    return {"lines": result.products, "errors": errors}


def _match_from_payload(hit: dict) -> ProductMatch | None:
    payload = hit.get("payload") or {}
    try:
        product_id = int(payload.get("product_id"))
        supplier_id = int(payload.get("supplier_id"))
    except (TypeError, ValueError):
        return None
    return ProductMatch(
        product_id=product_id,
        supplier_id=supplier_id,
        sku=str(payload.get("sku") or ""),
        unit_price=float(payload.get("price") or 0),
        category=str(payload.get("category") or ""),
        attributes={str(k): str(v) for k, v in (payload.get("attributes") or {}).items()},
        similarity_score=float(hit.get("similarity_score") or 0),
    )


def _confident_matches(matches: list[ProductMatch]) -> list[ProductMatch]:
    """Keep only catalog hits that clear the similarity threshold.

    Out-of-catalog terms (e.g. "coca-cola" against a PPE-only catalog) still
    return their nearest vector from Qdrant; anything below
    ``resolve_min_similarity`` is treated as a miss so the line ends up in
    ``unresolved`` instead of silently force-matching an unrelated product.
    """
    min_similarity = get_settings().resolve_min_similarity
    return [m for m in matches if m.similarity_score >= min_similarity]


def enrich_metadata_node(state: OrderState) -> dict:
    new_lines: list[OrderLine] = []
    for line in state["lines"]:
        if line.error:
            new_lines.append(line)
            continue
        query_text = " ".join(p for p in (line.product_name, line.category or "") if p).strip()
        query_text = query_text or line.product_name
        if not query_text:
            line.error = "Cannot resolve an empty product name"
            new_lines.append(line)
            continue
        query_vec = embed_sync(query_text)
        hits = vector_search(query_vec, limit=5)
        line.matches = _confident_matches(
            [m for m in (_match_from_payload(h) for h in hits) if m is not None]
        )
        new_lines.append(line)
    return {"lines": new_lines}


def resolve_defaults_node(state: OrderState) -> dict:
    new_lines: list[OrderLine] = []
    for line in state["lines"]:
        if line.error:
            new_lines.append(line)
            continue
        top = line.matches[0] if line.matches else None
        line.resolved_quantity = max(int(line.quantity or 1), 1)
        if top is None:
            line.error = f"No matching product found for {line.product_name!r} in the catalog"
            new_lines.append(line)
            continue
        attrs = dict(line.requested_attributes)
        for key, value in (top.attributes or {}).items():
            if key not in attrs:
                attrs[key] = value
        line.resolved_attributes = attrs
        line.resolved_unit_price = top.unit_price
        line.matched = top
        new_lines.append(line)
    return {"lines": new_lines}


def match_best_node(state: OrderState) -> dict:
    new_lines: list[OrderLine] = []
    location = state.get("customer_location")
    for line in state["lines"]:
        if line.error or line.resolved_unit_price is None:
            new_lines.append(line)
            continue
        attrs_text = ", ".join(f"{k}: {v}" for k, v in line.resolved_attributes.items() if v)
        query_text = " ".join(p for p in (line.product_name, attrs_text) if p) or line.product_name
        query_vec = embed_sync(query_text)
        hits = vector_search(
            query_vec,
            price_min=line.price_bound_min,
            price_max=line.price_bound_max,
            limit=10,
        )
        matches = _confident_matches(
            [m for m in (_match_from_payload(h) for h in hits) if m is not None]
        )
        if not matches:
            line.error = f"No in-stock product matched {line.product_name!r}"
            new_lines.append(line)
            continue

        if location is not None:
            ranked = blend_and_rank(hits, _DEFAULT_WEIGHTS, location, 50.0)
            by_id = {m.product_id: m for m in matches}
            top_id = ranked[0].product_id if ranked else None
            best = by_id.get(int(top_id)) if top_id is not None else None
            if best is None:
                best = matches[0]
        else:
            best = matches[0]

        line.matched = best
        line.resolved_unit_price = best.unit_price
        qty = max(int(line.resolved_quantity or 1), 1)
        line.subtotal = round(qty * best.unit_price, 2)
        new_lines.append(line)
    return {"lines": new_lines}


def generate_order_node(state: OrderState) -> dict:
    splits: list[OrderSplit] = []
    unresolved: list[str] = []
    total = 0.0
    for line in state["lines"]:
        best = line.matched
        if best is None or line.error:
            unresolved.append(line.product_name)
            continue
        qty = max(int(line.resolved_quantity or 1), 1)
        splits.append(OrderSplit(
            supplier_id=best.supplier_id,
            sku=best.sku,
            quantity_ordered=qty,
            sub_total_cost=round(line.subtotal, 2),
        ))
        total += line.subtotal
    order = OrderResponse(
        merchant_id=state["merchant_id"],
        total_order_cost=round(total, 2),
        splits=splits,
        unresolved=unresolved,
    )
    logger.info("order generated splits=%d unresolved=%d", len(splits), len(unresolved))
    return {"order": order}