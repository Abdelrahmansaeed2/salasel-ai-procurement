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


def test_asks_for_product_name_when_missing() -> None:
    state = make_state(ProductSpec())
    result = ask_missing_spec_node(state)
    assert result["missing_fields"] == ["product_name", "price"]
    assert result["messages"][0].content == FOLLOWUP_TEMPLATES["product_name"]


def test_no_missing_fields_when_product_name_given() -> None:
    spec = ProductSpec(product_name="gloves")
    state = make_state(spec)
    result = ask_missing_spec_node(state)
    assert result["missing_fields"] == ["price"]
    assert result["messages"][0].content == FOLLOWUP_TEMPLATES["price"]


def test_asks_for_price_when_missing() -> None:
    state = make_state(ProductSpec(product_name="gloves"))
    result = ask_missing_spec_node(state)
    assert result["missing_fields"] == ["price"]
    assert result["messages"][0].content == FOLLOWUP_TEMPLATES["price"]


def test_no_missing_fields_when_price_given() -> None:
    state = make_state(ProductSpec(product_name="gloves", price_max=50.0))
    result = ask_missing_spec_node(state)
    assert result["missing_fields"] == []
    assert "messages" not in result