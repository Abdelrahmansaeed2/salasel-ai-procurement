from unittest.mock import MagicMock, patch

from app.services.vector_store import ensure_collection, upsert


@patch("app.services.vector_store.get_client")
def test_ensure_collection_creates_if_not_exists(mock_get_client) -> None:
    mock_client = MagicMock()
    mock_get_client.return_value = mock_client
    mock_client.get_collections.return_value.collections = []

    ensure_collection(vector_size=384)

    mock_client.create_collection.assert_called_once()


@patch("app.services.vector_store.get_client")
def test_ensure_collection_skips_if_exists(mock_get_client) -> None:
    mock_client = MagicMock()
    mock_get_client.return_value = mock_client
    mock_collection = MagicMock()
    mock_collection.name = "products"
    mock_client.get_collections.return_value.collections = [mock_collection]

    ensure_collection(vector_size=384)

    mock_client.create_collection.assert_not_called()


@patch("app.services.vector_store.get_client")
def test_upsert_idempotent(mock_get_client) -> None:
    mock_client = MagicMock()
    mock_get_client.return_value = mock_client
    mock_client.get_collections.return_value.collections = []

    upsert("42", [0.1, 0.2, 0.3], {"category": "PPE"})
    upsert("42", [0.1, 0.2, 0.3], {"category": "PPE"})

    assert mock_client.upsert.call_count == 2
    for call_args in mock_client.upsert.call_args_list:
        kwargs = call_args[1]
        points = kwargs.get("points", [])
        for point in points:
            assert point.id == 42
