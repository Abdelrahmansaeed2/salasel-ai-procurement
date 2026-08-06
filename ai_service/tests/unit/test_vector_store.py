from unittest.mock import MagicMock, patch

from app.services.vector_store import (
    build_explore_filter,
    collection_info,
    count_products,
    ensure_collection,
    fetch_all_products,
    get_product,
    list_by_category,
    scroll_products,
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


def test_build_explore_filter_none_for_no_constraints() -> None:
    assert build_explore_filter() is None


def test_build_explore_filter_all_constraints() -> None:
    qdrant_filter = build_explore_filter(
        category="PPE",
        supplier_id=3,
        in_stock=True,
        price_min=1.0,
        price_max=50.0,
    )
    assert qdrant_filter is not None
    keys = [c.key for c in qdrant_filter.must]
    assert keys == ["category", "supplier_id", "in_stock", "price"]
    by_key = {c.key: c for c in qdrant_filter.must}
    assert by_key["category"].match.value == "PPE"
    assert by_key["supplier_id"].match.value == "3"
    assert by_key["in_stock"].match.value is True
    assert by_key["price"].range.gte == 1.0
    assert by_key["price"].range.lte == 50.0


@patch("app.services.vector_store.get_client")
def test_scroll_products_returns_records(mock_get_client) -> None:
    mock_client = MagicMock()
    mock_get_client.return_value = mock_client
    point = MagicMock()
    point.id = 1
    point.payload = {"product_id": "1", "product_name": "Gloves", "sku": "NG"}
    point.vector = [0.1, 0.2]
    mock_client.scroll.return_value = ([point], None)

    result = scroll_products(offset=5, limit=10, with_vectors=True)

    assert result == [{"id": 1, "product_id": "1", "product_name": "Gloves", "sku": "NG", "vector": [0.1, 0.2]}]
    scroll_call = mock_client.scroll.call_args[1]
    assert scroll_call["offset"] == 5
    assert scroll_call["limit"] == 10
    assert scroll_call["with_vectors"] is True
    assert scroll_call["scroll_filter"] is None


@patch("app.services.vector_store.get_client")
def test_scroll_products_zero_offset_passes_none(mock_get_client) -> None:
    mock_client = MagicMock()
    mock_get_client.return_value = mock_client
    mock_client.scroll.return_value = ([], None)

    scroll_products(offset=0, limit=50)

    assert mock_client.scroll.call_args[1]["offset"] is None


@patch("app.services.vector_store.get_client")
def test_count_products_uses_exact_count(mock_get_client) -> None:
    mock_client = MagicMock()
    mock_get_client.return_value = mock_client
    mock_client.count.return_value.count = 7

    assert count_products(category="PPE") == 7

    count_call = mock_client.count.call_args[1]
    assert count_call["exact"] is True
    assert count_call["count_filter"].must[0].key == "category"


@patch("app.services.vector_store.get_client")
def test_get_product_returns_record(mock_get_client) -> None:
    mock_client = MagicMock()
    mock_get_client.return_value = mock_client
    point = MagicMock()
    point.id = 42
    point.payload = {"product_id": "42", "price": 3.75}
    point.vector = [0.1]
    mock_client.retrieve.return_value = [point]

    result = get_product(42, with_vectors=True)

    assert result == {"id": 42, "product_id": "42", "price": 3.75, "vector": [0.1]}
    assert mock_client.retrieve.call_args[1]["ids"] == [42]


@patch("app.services.vector_store.get_client")
def test_get_product_missing_returns_none(mock_get_client) -> None:
    mock_client = MagicMock()
    mock_get_client.return_value = mock_client
    mock_client.retrieve.return_value = []

    assert get_product(999) is None


@patch("app.services.vector_store.get_client")
def test_collection_info(mock_get_client) -> None:
    mock_client = MagicMock()
    mock_get_client.return_value = mock_client
    info = MagicMock()
    info.config.params.vectors.size = 384
    info.config.params.vectors.distance = "Cosine"
    mock_client.get_collection.return_value = info
    mock_client.count.return_value.count = 3

    result = collection_info()

    assert result == {"collection": "products", "count": 3, "dimension": 384, "distance": "Cosine"}


def make_point(point_id: int, name: str):
    point = MagicMock()
    point.id = point_id
    point.payload = {"product_id": str(point_id), "product_name": name}
    point.vector = [0.1]
    return point


@patch("app.services.vector_store.get_client")
def test_fetch_all_products_single_page(mock_get_client) -> None:
    mock_client = MagicMock()
    mock_get_client.return_value = mock_client
    mock_client.scroll.return_value = ([make_point(1, "A"), make_point(2, "B")], None)

    result = fetch_all_products()

    assert result == [
        {"id": 1, "product_id": "1", "product_name": "A"},
        {"id": 2, "product_id": "2", "product_name": "B"},
    ]
    mock_client.scroll.assert_called_once()


@patch("app.services.vector_store.get_client")
def test_fetch_all_products_follows_cursor_across_pages(mock_get_client) -> None:
    mock_client = MagicMock()
    mock_get_client.return_value = mock_client
    mock_client.scroll.side_effect = [
        ([make_point(1, "A")], "next-token"),
        ([make_point(2, "B")], None),
    ]

    result = fetch_all_products(page_size=1)

    assert result == [
        {"id": 1, "product_id": "1", "product_name": "A"},
        {"id": 2, "product_id": "2", "product_name": "B"},
    ]
    assert mock_client.scroll.call_count == 2
    first = mock_client.scroll.call_args_list[0][1]
    assert first["limit"] == 1
    assert first["with_vectors"] is False
    assert first["offset"] is None
    second = mock_client.scroll.call_args_list[1][1]
    assert second["offset"] == "next-token"
