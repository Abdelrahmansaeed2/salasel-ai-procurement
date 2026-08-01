import logging

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import SupplierCatalog, SupplierProfile
from app.schemas.product import ProductUpsert
from app.services.embedding_service import build_product_text, embed
from app.services.ingestion_service import ingest_products, product_payload
from app.services.vector_store import upsert as vector_upsert

logger = logging.getLogger(__name__)


def _to_product_upsert(
    product_id: int,
    supplier_id: int,
    product_name: str,
    sku: str,
    category: str | None,
    unit_price: float,
    lat: float | None,
    lon: float | None,
    stock_available: int,
) -> ProductUpsert:
    return ProductUpsert(
        product_id=product_id,
        supplier_id=supplier_id,
        product_name=product_name,
        sku=sku,
        category=category or "",
        price=float(unit_price),
        lat=float(lat or 0),
        lon=float(lon or 0),
        in_stock=stock_available > 0,
    )


async def sync_product_to_vector_store(
    catalog: SupplierCatalog,
    supplier: SupplierProfile,
    session: AsyncSession | None = None,
) -> None:
    upsert = ProductUpsert(
        product_id=catalog.catalog_id,
        supplier_id=supplier.supplier_id,
        product_name=catalog.product_name,
        sku=catalog.sku,
        category=catalog.category or "",
        price=float(catalog.unit_price),
        lat=float(supplier.latitude or 0),
        lon=float(supplier.longitude or 0),
        in_stock=catalog.stock_available > 0,
    )
    text = build_product_text(upsert.product_name, upsert.sku, upsert.category)
    vector = await embed(text)
    vector_upsert(point_id=str(upsert.product_id), vector=vector, payload=product_payload(upsert))
    logger.info("Synced product %s to vector store", catalog.catalog_id)


async def sync_all_products(session: AsyncSession) -> None:
    query = (
        select(
            SupplierCatalog.catalog_id,
            SupplierCatalog.supplier_id,
            SupplierCatalog.sku,
            SupplierCatalog.product_name,
            SupplierCatalog.category,
            SupplierCatalog.unit_price,
            SupplierCatalog.stock_available,
            SupplierProfile.latitude,
            SupplierProfile.longitude,
        )
        .join(SupplierProfile)
    )
    rows = (await session.execute(query)).all()

    products = [
        _to_product_upsert(
            product_id=row.catalog_id,
            supplier_id=row.supplier_id,
            product_name=row.product_name,
            sku=row.sku,
            category=row.category,
            unit_price=float(row.unit_price),
            lat=row.latitude,
            lon=row.longitude,
            stock_available=row.stock_available,
        )
        for row in rows
    ]

    await ingest_products(products)
    logger.info("Synced %d products to vector store", len(products))
