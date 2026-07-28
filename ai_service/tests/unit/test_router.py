from app.agents.nodes.router import route_after_conversation
from app.agents.state import InventoryState, ProductSpec


def make_state(spec: ProductSpec) -> InventoryState:
    return InventoryState(
        messages=[],
        spec=spec,
        customer_location=None,
        candidates=[],
        ranked_results=[],
        rejected_ids=[],
        rank_weights={"sim": 1.0, "quality": 0.7, "distance": 0.5},
        missing_fields=[],
        turn_status="ask",
    )


def test_route_to_rag_when_needs_attribute_lookup() -> None:
    spec = ProductSpec(category="electronics", needs_attribute_lookup=True)
    state = make_state(spec)
    assert route_after_conversation(state) == "rag_lookup"


def test_route_to_rag_even_when_complete() -> None:
    spec = ProductSpec(
        category="electronics", price_min=10.0, price_max=100.0,
        is_complete=True, needs_attribute_lookup=True,
    )
    state = make_state(spec)
    assert route_after_conversation(state) == "rag_lookup"


def test_route_to_ask_missing_when_incomplete() -> None:
    spec = ProductSpec(category="electronics")
    state = make_state(spec)
    assert route_after_conversation(state) == "ask_missing_spec"


def test_route_to_ask_missing_when_empty_spec() -> None:
    spec = ProductSpec()
    state = make_state(spec)
    assert route_after_conversation(state) == "ask_missing_spec"


def test_route_to_retriever_when_complete() -> None:
    spec = ProductSpec(category="electronics", price_min=10.0, price_max=100.0)
    state = make_state(spec)
    assert route_after_conversation(state) == "retriever"
