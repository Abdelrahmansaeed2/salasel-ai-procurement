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
    query = select(SupplierCatalog).join(SupplierProfile)
    result = await session.execute(query)
    catalogs = result.scalars().all()

    for catalog in catalogs:
        await sync_product_to_vector_store(catalog, catalog.supplier, session)
    logger.info("Synced %d products to vector store", len(catalogs))
