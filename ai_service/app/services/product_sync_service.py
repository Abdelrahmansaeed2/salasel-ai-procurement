import logging

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import SupplierCatalog, SupplierProfile
from app.services.embedding_service import embed
from app.services.vector_store import upsert as vector_upsert

logger = logging.getLogger(__name__)


def _to_embedding_text(product_name: str, sku: str, category: str | None) -> str:
    parts = [product_name, sku]
    if category:
        parts.append(category)
    return " ".join(parts)


async def sync_product_to_vector_store(
    catalog: SupplierCatalog,
    supplier: SupplierProfile,
    session: AsyncSession | None = None,
) -> None:
    embedding_text = _to_embedding_text(
        catalog.product_name,
        catalog.sku,
        catalog.category,
    )
    vector = await embed(embedding_text)

    payload = {
        "product_id": str(catalog.catalog_id),
        "supplier_id": str(supplier.supplier_id),
        "category": catalog.category or "",
        "price": float(catalog.unit_price),
        "geo": {"lat": float(supplier.latitude or 0), "lon": float(supplier.longitude or 0)},
        "quality_score": None,
    }

    vector_upsert(point_id=str(catalog.catalog_id), vector=vector, payload=payload)
    logger.info("Synced product %s to vector store", catalog.catalog_id)


async def sync_all_products(session: AsyncSession) -> None:
    query = (
        select(
            SupplierCatalog.catalog_id,
            SupplierCatalog.sku,
            SupplierCatalog.product_name,
            SupplierCatalog.category,
            SupplierCatalog.unit_price,
            SupplierProfile.supplier_id,
            SupplierProfile.latitude,
            SupplierProfile.longitude,
        )
        .join(SupplierProfile)
    )
    rows = (await session.execute(query)).all()

    for row in rows:
        embedding_text = _to_embedding_text(row.product_name, row.sku, row.category)
        vector = await embed(embedding_text)
        payload = {
            "product_id": str(row.catalog_id),
            "supplier_id": str(row.supplier_id),
            "category": row.category or "",
            "price": float(row.unit_price),
            "geo": {"lat": float(row.latitude or 0), "lon": float(row.longitude or 0)},
            "quality_score": None,
        }
        vector_upsert(point_id=str(row.catalog_id), vector=vector, payload=payload)
        logger.info("Synced product %s to vector store", row.catalog_id)

    logger.info("Synced %d products to vector store", len(rows))
