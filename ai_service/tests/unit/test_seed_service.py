from unittest.mock import AsyncMock, MagicMock, patch

from app.services.seed_service import (
    DEFAULT_VECTOR_SIZE,
    SEED_PRODUCTS,
    SEED_SUPPLIER_METRICS,
    seed_dev_data,
)


def test_seed_dataset_shape() -> None:
    product_ids = [p.product_id for p in SEED_PRODUCTS]
    assert len(product_ids) == len(set(product_ids))
    assert 8 <= len(SEED_PRODUCTS) <= 12
    categories = {p.category for p in SEED_PRODUCTS}
    assert {"PPE", "janitorial"}.issubset(categories)
    assert any(p.in_stock is False for p in SEED_PRODUCTS)
    suppliers = {p.supplier_id for p in SEED_PRODUCTS}
    assert len(suppliers) == 3
    assert {m.supplier_id for m in SEED_SUPPLIER_METRICS} == suppliers


@patch("app.services.seed_service.update_payloads_by_supplier")
@patch("app.services.seed_service.compute_scores")
@patch("app.services.seed_service.ingest_products", new_callable=AsyncMock)
@patch("app.services.seed_service.collection_info")
@patch("app.services.seed_service.ensure_collection")
async def test_seed_populates_empty_collection(
    mock_ensure: MagicMock,
    mock_info: MagicMock,
    mock_ingest: AsyncMock,
    mock_compute: MagicMock,
    mock_update: MagicMock,
) -> None:
    mock_info.return_value = {"count": 0}
    mock_ingest.return_value = len(SEED_PRODUCTS)
    mock_compute.return_value = [(1, 90.0), (2, 80.0)]

    seeded = await seed_dev_data()

    assert seeded is True
    mock_ensure.assert_called_once_with(DEFAULT_VECTOR_SIZE)
    mock_ingest.assert_awaited_once_with(SEED_PRODUCTS)
    mock_compute.assert_called_once_with(SEED_SUPPLIER_METRICS)
    mock_update.assert_called_once_with([(1, 90.0), (2, 80.0)])


@patch("app.services.seed_service.update_payloads_by_supplier")
@patch("app.services.seed_service.compute_scores")
@patch("app.services.seed_service.ingest_products", new_callable=AsyncMock)
@patch("app.services.seed_service.collection_info")
@patch("app.services.seed_service.ensure_collection")
async def test_seed_skips_when_collection_non_empty(
    mock_ensure: MagicMock,
    mock_info: MagicMock,
    mock_ingest: AsyncMock,
    mock_compute: MagicMock,
    mock_update: MagicMock,
) -> None:
    mock_info.return_value = {"count": 5}

    seeded = await seed_dev_data()

    assert seeded is False
    mock_ingest.assert_not_awaited()
    mock_compute.assert_not_called()
    mock_update.assert_not_called()
