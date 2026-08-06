import logging

from fastapi import APIRouter

from app.db.session import get_sessionmaker
from app.schemas.product import ProductUpsertBatch, QualityMetricsBatch
from app.services.ingestion_service import ingest_products
from app.services.product_sync_service import sync_all_products
from app.services.quality_score_service import compute_scores
from app.services.vector_store import update_payloads_by_supplier

logger = logging.getLogger(__name__)
router = APIRouter(tags=["admin"])


@router.post("/admin/sync-products")
async def admin_sync_products() -> dict:
    async with get_sessionmaker()() as session:
        await sync_all_products(session)
    return {"status": "ok", "message": "Products synced to vector store"}


@router.post("/admin/products")
async def admin_ingest_products(batch: ProductUpsertBatch) -> dict:
    synced = await ingest_products(batch.products)
    return {"status": "ok", "synced": synced}


@router.post("/admin/quality-metrics")
async def admin_quality_metrics(batch: QualityMetricsBatch) -> dict:
    scores = compute_scores(batch.metrics)
    update_payloads_by_supplier(scores)
    return {"status": "ok", "updated_suppliers": len(scores)}
