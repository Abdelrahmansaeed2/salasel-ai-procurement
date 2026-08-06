from unittest.mock import MagicMock, patch

from app.services.vector_store import (
    ensure_collection,
    list_by_category,
    update_payloads_by_supplier,
    upsert,
)


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


@patch("app.services.vector_store.get_client")
def test_list_by_category_scrolls_payload(mock_get_client) -> None:
    mock_client = MagicMock()
    mock_get_client.return_value = mock_client
    point = MagicMock()
    point.payload = {"product_name": "Gloves", "sku": "NG", "price": 3.75}
    mock_client.scroll.return_value = ([point], None)

    result = list_by_category("PPE")

    assert result == [{"product_name": "Gloves", "sku": "NG", "price": 3.75}]
    scroll_filter = mock_client.scroll.call_args[1]["scroll_filter"]
    assert scroll_filter.must[0].key == "category"
    assert scroll_filter.must[0].match.value == "PPE"
    assert scroll_filter.must[1].key == "in_stock"


@patch("app.services.vector_store.get_client")
def test_list_by_category_without_stock_filter(mock_get_client) -> None:
    mock_client = MagicMock()
    mock_get_client.return_value = mock_client
    mock_client.scroll.return_value = ([], None)

    list_by_category("PPE", in_stock_only=False)

    scroll_filter = mock_client.scroll.call_args[1]["scroll_filter"]
    assert len(scroll_filter.must) == 1
    assert scroll_filter.must[0].key == "category"


@patch("app.services.vector_store.get_client")
def test_update_payloads_by_supplier_sets_scores(mock_get_client) -> None:
    mock_client = MagicMock()
    mock_get_client.return_value = mock_client
    p1 = MagicMock()
    p1.id = 5
    p2 = MagicMock()
    p2.id = 9
    mock_client.scroll.return_value = ([p1, p2], None)

    update_payloads_by_supplier([(3, 92.5)])

    scroll_filter = mock_client.scroll.call_args[1]["scroll_filter"]
    assert scroll_filter.must[0].key == "supplier_id"
    assert scroll_filter.must[0].match.value == "3"
    mock_client.set_payload.assert_called_once()
    call = mock_client.set_payload.call_args[1]
    assert call["payload"] == {"quality_score": 92.5}
    assert call["points"] == [5, 9]


@patch("app.services.vector_store.get_client")
def test_update_payloads_by_supplier_skips_empty(mock_get_client) -> None:
    mock_client = MagicMock()
    mock_get_client.return_value = mock_client
    mock_client.scroll.return_value = ([], None)

    update_payloads_by_supplier([(3, 92.5)])

    mock_client.set_payload.assert_not_called()


@patch("app.services.vector_store.get_client")
def test_update_payloads_by_supplier_noop_for_empty_scores(mock_get_client) -> None:
    update_payloads_by_supplier([])
    mock_get_client.assert_not_called()
