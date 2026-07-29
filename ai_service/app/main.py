import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.agents.checkpointer import close_checkpointer
from app.api.v1.admin import router as admin_router
from app.api.v1.chat import router as chat_router
from app.api.v1.health import router as health_router
from app.core.config import get_settings
from app.db.session import get_sessionmaker
from app.services.product_sync_service import sync_all_products

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        async with get_sessionmaker()() as session:
            await sync_all_products(session)
    except Exception:
        logger.exception("Failed to sync products to vector store on startup")
    yield
    close_checkpointer()


def create_app() -> FastAPI:
    settings = get_settings()
    app = FastAPI(title=settings.app_name, lifespan=lifespan)
    app.include_router(health_router, prefix=settings.api_v1_prefix)
    app.include_router(chat_router, prefix=settings.api_v1_prefix)
    app.include_router(admin_router, prefix=settings.api_v1_prefix)
    return app


app = create_app()
