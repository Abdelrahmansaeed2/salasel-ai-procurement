import json
from unittest.mock import MagicMock, patch

from app.agents.nodes.resolve_product import resolve_product_node
from app.agents.state import InventoryState, ProductSpec

CACHE_KEY = "resolve:gloves"
HIT = [{
    "similarity_score": 0.83,
    "payload": {"category": "PPE", "product_name": "Nitrile Gloves", "attributes": {"size": "L"}},
}]


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


def make_redis_cache(value: bytes | None) -> MagicMock:
    redis_client = MagicMock()
    redis_client.get.return_value = value
    return redis_client


@patch("app.agents.nodes.resolve_product.Redis")
def test_resolves_category_from_top_hit(mock_redis_cls) -> None:
    mock_redis_cls.from_url.return_value = make_redis_cache(None)
    with patch("app.agents.nodes.resolve_product.vector_search", return_value=HIT) as mock_search:
        result = resolve_product_node(make_state(ProductSpec(product_name="gloves")))

    spec = result["spec"]
    assert spec.category == "PPE"
    assert spec.required_attributes == {}
    assert spec.needs_attribute_lookup is False
    assert "Nitrile Gloves" in result["messages"][-1].content
    mock_search.assert_called_once()


@patch("app.agents.nodes.resolve_product.Redis")
def test_cache_hit_skips_search(mock_redis_cls) -> None:
    mock_redis_cls.from_url.return_value = make_redis_cache(json.dumps(HIT).encode("utf-8"))
    with patch("app.agents.nodes.resolve_product.vector_search") as mock_search:
        result = resolve_product_node(make_state(ProductSpec(product_name="gloves")))

    assert result["spec"].category == "PPE"
    mock_search.assert_not_called()


@patch("app.agents.nodes.resolve_product.Redis")
def test_no_hits_returns_guidance(mock_redis_cls) -> None:
    mock_redis_cls.from_url.return_value = make_redis_cache(None)
    with patch("app.agents.nodes.resolve_product.vector_search", return_value=[]):
        result = resolve_product_node(make_state(ProductSpec(product_name="unicorn")))

    spec = result["spec"]
    assert spec.category is None
    assert spec.needs_attribute_lookup is False
    assert "couldn't find" in result["messages"][-1].content


@patch("app.agents.nodes.resolve_product.Redis")
def test_low_similarity_hit_returns_guidance(mock_redis_cls) -> None:
    mock_redis_cls.from_url.return_value = make_redis_cache(None)
    low_hit = [{"similarity_score": 0.4, "payload": {"category": "PPE", "product_name": "Gloves"}}]
    with patch("app.agents.nodes.resolve_product.vector_search", return_value=low_hit):
        result = resolve_product_node(make_state(ProductSpec(product_name="unicorn plush toy")))

    assert result["spec"].category is None
    assert "couldn't find" in result["messages"][-1].content


@patch("app.agents.nodes.resolve_product.Redis")
def test_missing_product_name_guard(mock_redis_cls) -> None:
    result = resolve_product_node(make_state(ProductSpec()))

    assert result["spec"].category is None
    assert "What product are you looking for?" in result["messages"][-1].content
    mock_redis_cls.from_url.assert_not_called()
