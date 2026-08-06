from app.agents.nodes.ask_missing_spec import FOLLOWUP_TEMPLATES, ask_missing_spec_node
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


def test_asks_for_category_when_missing() -> None:
    state = make_state(ProductSpec())
    result = ask_missing_spec_node(state)
    assert result["missing_fields"] == ["category", "price_min", "price_max"]
    assert result["messages"][0].content == FOLLOWUP_TEMPLATES["category"]


def test_asks_for_price_min_when_category_given() -> None:
    spec = ProductSpec(category="electronics")
    state = make_state(spec)
    result = ask_missing_spec_node(state)
    assert result["missing_fields"] == ["price_min", "price_max"]
    assert result["messages"][0].content == FOLLOWUP_TEMPLATES["price_min"]


def test_asks_for_price_max_when_only_category_and_min_price() -> None:
    spec = ProductSpec(category="electronics", price_min=10.0)
    state = make_state(spec)
    result = ask_missing_spec_node(state)
    assert result["missing_fields"] == ["price_max"]
    assert result["messages"][0].content == FOLLOWUP_TEMPLATES["price_max"]


def test_no_missing_fields_when_spec_complete() -> None:
    spec = ProductSpec(category="electronics", price_min=10.0, price_max=100.0)
    state = make_state(spec)
    result = ask_missing_spec_node(state)
    assert result["missing_fields"] == []
    assert "messages" not in result
