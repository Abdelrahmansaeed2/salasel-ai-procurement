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

    mock_session = MagicMock()
    mock_result = MagicMock()
    mock_result.all.return_value = [
        ("Nitrile Gloves Medium", "PPE-GLOVES-NITRILE-M", 3.75),
    ]
    mock_session.execute.return_value = mock_result

    with patch("app.agents.nodes.rag_lookup.Redis.from_url", return_value=mock_redis), \
         patch("app.agents.nodes.rag_lookup.get_sync_sessionmaker") as mock_sm, \
         patch("app.agents.nodes.rag_lookup.ProductRepository") as mock_repo_cls:

        mock_sm_instance = MagicMock()
        mock_sm_instance.return_value = mock_session
        mock_sm.return_value = mock_sm_instance

        mock_repo = MagicMock()
        mock_repo_cls.return_value = mock_repo
        mock_repo.get_distinct_attributes_sync.return_value = [
            "Nitrile Gloves Medium (SKU: PPE-GLOVES-NITRILE-M, $3.75)",
        ]

        from app.agents.nodes.rag_lookup import rag_lookup_node
        result = rag_lookup_node(state)

    assert result["spec"].needs_attribute_lookup is False
    assert len(result["messages"]) == 1
    content = result["messages"][0].content
    assert "PPE" in content
    assert "Nitrile Gloves Medium" in content
    mock_repo.get_distinct_attributes_sync.assert_called_once_with("PPE")


def test_rag_lookup_cache_hit() -> None:
    spec = ProductSpec(category="PPE", needs_attribute_lookup=True)
    state = make_state(spec)

    cached_attrs = ["Nitrile Gloves Medium (SKU: PPE-GLOVES-NITRILE-M, $3.75)"]
    mock_redis = MagicMock()
    mock_redis.get.return_value = json.dumps(cached_attrs).encode()

    with patch("app.agents.nodes.rag_lookup.Redis.from_url", return_value=mock_redis), \
         patch("app.agents.nodes.rag_lookup.get_sync_sessionmaker") as mock_sm:

        from app.agents.nodes.rag_lookup import rag_lookup_node
        result = rag_lookup_node(state)

    assert result["spec"].needs_attribute_lookup is False
    assert len(result["messages"]) == 1
    mock_sm.assert_not_called()


def test_rag_lookup_handles_none_category() -> None:
    state = make_state(ProductSpec())
    from app.agents.nodes.rag_lookup import rag_lookup_node
    result = rag_lookup_node(state)

    assert result["spec"].needs_attribute_lookup is False
    assert "category" in result["messages"][0].content.lower()
