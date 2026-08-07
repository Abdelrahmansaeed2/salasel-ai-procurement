from unittest.mock import AsyncMock, MagicMock, patch

from app.schemas.product import ProductUpsert
from app.services.ingestion_service import ingest_products, product_payload, update_product


def make_product(product_id: int = 1, **overrides: object) -> ProductUpsert:
    base = {
        "product_id": product_id,
        "supplier_id": 1,
        "product_name": "Nitrile Gloves",
        "sku": "NG-MED",
        "category": "PPE",
        "description": "Disposable exam gloves",
        "attributes": {"size": "M"},
        "price": 3.75,
        "lat": 30.1,
        "lon": 31.2,
        "in_stock": True,
    }
    base.update(overrides)
    return ProductUpsert(**base)


def test_product_payload_shape() -> None:
    payload = product_payload(make_product(product_id=7, supplier_id=3))
    assert payload["product_id"] == "7"
    assert payload["supplier_id"] == "3"
    assert payload["category"] == "PPE"
    assert payload["description"] == "Disposable exam gloves"
    assert payload["attributes"] == {"size": "M"}
    assert payload["geo"] == {"lat": 30.1, "lon": 31.2}
    assert payload["quality_score"] is None
    assert payload["in_stock"] is True


def test_product_payload_defaults() -> None:
    payload = product_payload(make_product(in_stock=False, description=""))
    assert payload["in_stock"] is False
    assert payload["description"] == ""
    assert payload["attributes"] == {"size": "M"}


@patch("app.services.ingestion_service.vector_upsert")
@patch("app.services.ingestion_service.embed", new_callable=AsyncMock)
async def test_ingest_products_embeds_and_upserts(mock_embed: AsyncMock, mock_upsert: MagicMock) -> None:
    mock_embed.return_value = [0.1, 0.2, 0.3]
    products = [make_product(1), make_product(2, product_name="KN95 Masks")]
    count = await ingest_products(products)

    assert count == 2
    assert mock_embed.await_count == 2
    assert mock_upsert.call_count == 2
    first = mock_upsert.call_args_list[0][1]
    assert first["point_id"] == "1"
    assert first["vector"] == [0.1, 0.2, 0.3]
    assert first["payload"]["quality_score"] is None
    assert first["payload"]["product_name"] == "Nitrile Gloves"


@patch("app.services.ingestion_service.get_product")
@patch("app.services.ingestion_service.vector_upsert")
@patch("app.services.ingestion_service.embed", new_callable=AsyncMock)
async def test_update_product_missing_returns_none(
    mock_embed: AsyncMock, mock_upsert: MagicMock, mock_get_product: MagicMock
) -> None:
    mock_get_product.return_value = None

    result = await update_product(1, make_product(1))

    assert result is None
    mock_embed.assert_not_awaited()
    mock_upsert.assert_not_called()


@patch("app.services.ingestion_service.get_product")
@patch("app.services.ingestion_service.update_payloads")
@patch("app.services.ingestion_service.vector_upsert")
@patch("app.services.ingestion_service.embed", new_callable=AsyncMock)
async def test_update_product_reembeds_and_preserves_quality_score(
    mock_embed: AsyncMock, mock_upsert: MagicMock, mock_update_payloads: MagicMock, mock_get_product: MagicMock
) -> None:
    mock_get_product.return_value = {"quality_score": 88.5}
    mock_embed.return_value = [0.1, 0.2, 0.3]

    result = await update_product(1, make_product(1, product_name="Changed Name", attributes={"size": "L"}))

    assert result == {"re_embedded": True}
    mock_embed.assert_awaited_once()
    first = mock_upsert.call_args[1]
    assert first["point_id"] == "1"
    assert first["vector"] == [0.1, 0.2, 0.3]
    assert first["payload"]["quality_score"] == 88.5
    assert first["payload"]["product_name"] == "Changed Name"
    mock_update_payloads.assert_not_called()


@patch("app.services.ingestion_service.get_product")
@patch("app.services.ingestion_service.update_payloads")
@patch("app.services.ingestion_service.vector_upsert")
@patch("app.services.ingestion_service.embed", new_callable=AsyncMock)
async def test_update_product_price_only_is_payload_only(
    mock_embed: AsyncMock, mock_upsert: MagicMock, mock_update_payloads: MagicMock, mock_get_product: MagicMock
) -> None:
    mock_get_product.return_value = {
        **product_payload(make_product(1)),
        "quality_score": 77.0,
    }

    result = await update_product(1, make_product(1, price=9.99, in_stock=False))

    assert result == {"re_embedded": False}
    mock_embed.assert_not_awaited()
    mock_upsert.assert_not_called()
    mock_update_payloads.assert_called_once()
    pid, payload = mock_update_payloads.call_args[0][0][0]
    assert pid == "1"
    assert payload["price"] == 9.99
    assert payload["in_stock"] is False
    assert payload["quality_score"] == 77.0
