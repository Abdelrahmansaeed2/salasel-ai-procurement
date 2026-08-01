import json
from unittest.mock import MagicMock, patch

from app.agents.state import InventoryState, ProductSpec


def make_state(spec: ProductSpec | None = None) -> InventoryState:
    return InventoryState(
        messages=[],
        spec=spec or ProductSpec(),
        customer_location=None,
        candidates=[],
        ranked_results=[],
        rejected_ids=[],
        rank_weights={"sim": 1.0, "quality": 0.7, "distance": 0.5},
        missing_fields=[],
        turn_status="ask",
    )


def test_rag_lookup_returns_attributes_for_category() -> None:
    spec = ProductSpec(category="PPE", needs_attribute_lookup=True)
    state = make_state(spec)

    mock_redis = MagicMock()
    mock_redis.get.return_value = None

    with patch("app.agents.nodes.rag_lookup.Redis.from_url", return_value=mock_redis), \
         patch("app.agents.nodes.rag_lookup.list_by_category", return_value=[
             {"product_name": "Nitrile Gloves Medium", "sku": "PPE-GLOVES-NITRILE-M", "price": 3.75},
         ]) as mock_list:

        from app.agents.nodes.rag_lookup import rag_lookup_node
        result = rag_lookup_node(state)

    assert result["spec"].needs_attribute_lookup is False
    assert len(result["messages"]) == 1
    content = result["messages"][0].content
    assert "PPE" in content
    assert "Nitrile Gloves Medium (SKU: PPE-GLOVES-NITRILE-M, $3.75)" in content
    mock_list.assert_called_once_with("PPE", in_stock_only=True)


def test_rag_lookup_returns_no_products_message() -> None:
    spec = ProductSpec(category="PPE", needs_attribute_lookup=True)
    state = make_state(spec)

    mock_redis = MagicMock()
    mock_redis.get.return_value = None

    with patch("app.agents.nodes.rag_lookup.Redis.from_url", return_value=mock_redis), \
         patch("app.agents.nodes.rag_lookup.list_by_category", return_value=[]):

        from app.agents.nodes.rag_lookup import rag_lookup_node
        result = rag_lookup_node(state)

    assert "No products found for category: PPE" in result["messages"][0].content


def test_rag_lookup_cache_hit() -> None:
    spec = ProductSpec(category="PPE", needs_attribute_lookup=True)
    state = make_state(spec)

    cached_attrs = ["Nitrile Gloves Medium (SKU: PPE-GLOVES-NITRILE-M, $3.75)"]
    mock_redis = MagicMock()
    mock_redis.get.return_value = json.dumps(cached_attrs).encode()

    with patch("app.agents.nodes.rag_lookup.Redis.from_url", return_value=mock_redis), \
         patch("app.agents.nodes.rag_lookup.list_by_category") as mock_list:

        from app.agents.nodes.rag_lookup import rag_lookup_node
        result = rag_lookup_node(state)

    assert result["spec"].needs_attribute_lookup is False
    assert len(result["messages"]) == 1
    mock_list.assert_not_called()


def test_rag_lookup_handles_none_category() -> None:
    state = make_state(ProductSpec())
    from app.agents.nodes.rag_lookup import rag_lookup_node
    result = rag_lookup_node(state)

    assert result["spec"].needs_attribute_lookup is False
    assert "category" in result["messages"][0].content.lower()
