from app.agents.graph import route_after_attribute, route_after_resolve, route_after_retriever
from app.agents.nodes.router import route_after_conversation
from app.agents.state import Candidate, InventoryState, ProductSpec


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


def test_route_to_ask_when_empty_spec() -> None:
    assert route_after_conversation(make_state(ProductSpec())) == "ask_missing_spec"


def test_route_to_ask_when_product_name_missing() -> None:
    spec = ProductSpec(category=None, price_min=10.0, price_max=100.0)
    assert route_after_conversation(make_state(spec)) == "ask_missing_spec"


def test_route_to_ask_when_product_name_blank() -> None:
    spec = ProductSpec(product_name="   ")
    assert route_after_conversation(make_state(spec)) == "ask_missing_spec"


def test_route_to_resolve_when_category_unknown() -> None:
    spec = ProductSpec(product_name="gloves", price_max=50.0)
    assert route_after_conversation(make_state(spec)) == "resolve_product"


def test_route_to_resolve_when_needs_attribute_lookup() -> None:
    spec = ProductSpec(product_name="gloves", category="PPE", price_max=50.0, needs_attribute_lookup=True)
    assert route_after_conversation(make_state(spec)) == "resolve_product"


def test_route_to_retriever_when_resolved() -> None:
    spec = ProductSpec(product_name="gloves", category="PPE", price_max=50.0)
    assert route_after_conversation(make_state(spec)) == "retriever"


def test_route_to_ask_attributes_when_pending() -> None:
    spec = ProductSpec(product_name="gloves", category="PPE", price_max=50.0)
    state = make_state(spec)
    state["pending_attributes"] = ["material"]
    assert route_after_conversation(state) == "ask_attributes"


def test_route_after_resolve_hit_goes_to_ask_attributes() -> None:
    spec = ProductSpec(product_name="gloves", category="PPE", price_max=50.0)
    assert route_after_resolve(make_state(spec)) == "ask_attributes"


def test_route_after_resolve_miss_ends() -> None:
    spec = ProductSpec(product_name="unicorn", category=None)
    assert route_after_resolve(make_state(spec)) == "__end__"


def test_route_after_attribute_with_prompt_ends() -> None:
    state = make_state(ProductSpec(product_name="gloves", category="PPE", price_max=50.0))
    state["attribute_prompt"] = "Which size do you need?"
    assert route_after_attribute(state) == "__end__"


def test_route_after_attribute_without_prompt_goes_to_retriever() -> None:
    state = make_state(ProductSpec(product_name="gloves", category="PPE", price_max=50.0))
    state["attribute_prompt"] = None
    assert route_after_attribute(state) == "retriever"


def test_route_after_retriever_with_results_goes_to_format() -> None:
    state = make_state(ProductSpec(product_name="gloves", category="PPE", price_max=50.0))
    state["ranked_results"] = [
        Candidate(product_id="P1", supplier_id="S1", similarity_score=0.9, quality_score=0.7, distance_km=5.0, price=100.0)
    ]
    assert route_after_retriever(state) == "format_results"


def test_route_after_retriever_without_results_ends() -> None:
    state = make_state(ProductSpec(product_name="gloves", category="PPE", price_max=50.0))
    assert route_after_retriever(state) == "__end__"