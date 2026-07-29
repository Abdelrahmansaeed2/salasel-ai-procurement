import logging

from fastapi import APIRouter

from app.db.session import get_sessionmaker
from app.services.product_sync_service import sync_all_products

logger = logging.getLogger(__name__)
router = APIRouter(tags=["admin"])


@router.post("/admin/sync-products")
async def admin_sync_products() -> dict:
    async with get_sessionmaker()() as session:
        await sync_all_products(session)
    return {"status": "ok", "message": "Products synced to vector store"}
