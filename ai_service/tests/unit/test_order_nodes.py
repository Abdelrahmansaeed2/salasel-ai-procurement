from unittest.mock import MagicMock, patch

from app.agents.order.state import ExtractedOrders, OrderLine, OrderState, ProductMatch
from app.agents.state import Candidate
from app.schemas.order import OrderResponse


def make_state(**overrides) -> OrderState:
    state: OrderState = {
        "transcript": "I need 5 boxes of nitrile gloves",
        "merchant_id": 42,
        "customer_location": None,
        "lines": [],
        "order": None,
        "errors": [],
    }
    state.update(overrides)
    return state


def make_line(product_name: str = "Nitrile Gloves", **overrides) -> OrderLine:
    line = OrderLine(
        product_name=product_name,
        quantity=5,
        category="PPE",
        requested_attributes={"size": "M"},
    )
    for key, value in overrides.items():
        setattr(line, key, value)
    return line


def make_match(product_id: int, price: float, sku: str = "NG") -> ProductMatch:
    return ProductMatch(
        product_id=product_id,
        supplier_id=10,
        sku=sku,
        unit_price=price,
        category="PPE",
        attributes={"size": "M"},
        similarity_score=0.9,
    )


def make_payload(product_id: int, price: float, sku: str = "NG") -> dict:
    return {
        "product_id": str(product_id),
        "supplier_id": "10",
        "sku": sku,
        "price": price,
        "category": "PPE",
        "attributes": {"size": "M"},
    }


def test_extract_products_node_parses_transcript() -> None:
    from app.agents.order import nodes

    fake = MagicMock()
    fake.invoke.return_value = ExtractedOrders(products=[
        OrderLine(product_name="Nitrile Gloves", quantity=5),
    ])
    with patch.object(nodes, "_build_extract_chain", return_value=fake):
        result = nodes.extract_products_node(make_state())

    assert len(result["lines"]) == 1
    assert result["lines"][0].product_name == "Nitrile Gloves"
    assert result["lines"][0].quantity == 5
    assert result["errors"] == []


def test_extract_products_node_flags_empty() -> None:
    from app.agents.order import nodes

    fake = MagicMock()
    fake.invoke.return_value = ExtractedOrders(products=[])
    with patch.object(nodes, "_build_extract_chain", return_value=fake):
        result = nodes.extract_products_node(make_state())

    assert result["lines"] == []
    assert result["errors"] == ["No products were extracted from the transcript"]


@patch("app.agents.order.nodes.vector_search")
@patch("app.agents.order.nodes.embed_sync")
def test_enrich_metadata_node_attaches_matches(mock_embed, mock_search) -> None:
    from app.agents.order import nodes

    mock_embed.return_value = [0.1, 0.2]
    mock_search.return_value = [
        {"payload": make_payload(1, 3.75), "similarity_score": 0.92},
        {"payload": make_payload(2, 4.10), "similarity_score": 0.85},
    ]
    state = make_state(lines=[make_line()])

    result = nodes.enrich_metadata_node(state)

    assert len(result["lines"][0].matches) == 2
    assert result["lines"][0].matches[0].product_id == 1
    assert result["lines"][0].matches[0].unit_price == 3.75
    mock_search.assert_called_once()
    mock_search.assert_called_once()


def test_enrich_metadata_skips_error_lines() -> None:
    from app.agents.order import nodes

    line = make_line()
    line.error = "broken"
    state = make_state(lines=[line])

    result = nodes.enrich_metadata_node(state)

    assert result["lines"][0].matches == []


def test_resolve_defaults_node_applies_user_and_catalog_values() -> None:
    from app.agents.order import nodes

    line = make_line(quantity=None, requested_attributes={})
    line.matches = [make_match(1, 3.75)]
    state = make_state(lines=[line])

    result = nodes.resolve_defaults_node(state)

    resolved = result["lines"][0]
    assert resolved.resolved_quantity == 1
    assert resolved.resolved_unit_price == 3.75
    assert resolved.resolved_attributes == {"size": "M"}
    assert resolved.matched is not None


def test_resolve_defaults_flags_no_match() -> None:
    from app.agents.order import nodes

    line = make_line()
    state = make_state(lines=[line])

    result = nodes.resolve_defaults_node(state)

    assert result["lines"][0].error is not None
    assert result["lines"][0].resolved_quantity == 5


@patch("app.agents.order.nodes.vector_search")
@patch("app.agents.order.nodes.embed_sync")
def test_match_best_node_picks_top_and_computes_subtotal(mock_embed, mock_search) -> None:
    from app.agents.order import nodes

    mock_embed.return_value = [0.1]
    mock_search.return_value = [
        {"payload": make_payload(1, 3.75, sku="NG-M"), "similarity_score": 0.95},
        {"payload": make_payload(2, 4.10, sku="NG-L"), "similarity_score": 0.90},
    ]
    line = make_line(quantity=5)
    line.matches = [make_match(1, 3.75)]
    line.resolved_quantity = 5
    line.resolved_unit_price = 3.75
    state = make_state(lines=[line])

    result = nodes.match_best_node(state)

    best = result["lines"][0]
    assert best.matched is not None
    assert best.matched.product_id == 1
    assert best.matched.sku == "NG-M"
    assert best.subtotal == round(5 * 3.75, 2)


@patch("app.agents.order.nodes.blend_and_rank")
@patch("app.agents.order.nodes.vector_search")
@patch("app.agents.order.nodes.embed_sync")
def test_match_best_node_uses_blend_with_location(mock_embed, mock_search, mock_blend) -> None:
    from app.agents.order import nodes

    mock_embed.return_value = [0.1]
    mock_search.return_value = [
        {"payload": make_payload(1, 3.75, sku="NG-M"), "similarity_score": 0.95},
        {"payload": make_payload(2, 4.10, sku="NG-L"), "similarity_score": 0.90},
    ]
    mock_blend.return_value = [
        Candidate(product_id="2", supplier_id="10", similarity_score=0.9, quality_score=2.0, distance_km=1.0, price=4.10),
    ]
    line = make_line(quantity=5)
    line.matches = [make_match(1, 3.75), make_match(2, 4.10, sku="NG-L")]
    line.resolved_quantity = 5
    line.resolved_unit_price = 3.75
    state = make_state(lines=[line], customer_location=(30.0, 31.0))

    result = nodes.match_best_node(state)

    best = result["lines"][0]
    assert best.matched is not None
    assert best.matched.product_id == 2
    assert best.matched.sku == "NG-L"


def test_generate_order_node_aggregates_schema() -> None:
    from app.agents.order import nodes

    first = make_line(product_name="Nitrile Gloves", quantity=5)
    first.matched = make_match(1, 3.75, sku="NG-M")
    first.resolved_quantity = 5
    first.subtotal = round(5 * 3.75, 2)

    second = make_line(product_name="Safety Goggles", quantity=2)
    second.matched = make_match(7, 1.85, sku="GOG")
    second.resolved_quantity = 2
    second.subtotal = round(2 * 1.85, 2)

    unresolved = make_line(product_name="Unknown Item")
    unresolved.matched = None

    state = make_state(lines=[first, second, unresolved], merchant_id=42)

    result = nodes.generate_order_node(state)

    order: OrderResponse = result["order"]
    assert isinstance(order, OrderResponse)
    assert order.merchant_id == 42
    assert len(order.splits) == 2
    assert order.total_order_cost == round(5 * 3.75 + 2 * 1.85, 2)
    assert order.unresolved == ["Unknown Item"]
    assert order.splits[0].supplier_id == 10
    assert order.splits[0].sku == "NG-M"
    assert order.splits[0].quantity_ordered == 5
    assert order.splits[0].sub_total_cost == round(5 * 3.75, 2)