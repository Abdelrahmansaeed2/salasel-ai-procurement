import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.agents.checkpointer import close_checkpointer
from app.api.v1.admin import router as admin_router
from app.api.v1.chat import router as chat_router
from app.api.v1.health import router as health_router
from app.api.v1.voice import router as voice_router
from app.core.config import get_settings
from app.db.session import get_sessionmaker, get_sync_sessionmaker
from app.services.product_sync_service import sync_all_products
from app.services.quality_score_job import run_quality_score_update
from app.worker.quality_score_scheduler import start_scheduler, stop_scheduler

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        async with get_sessionmaker()() as session:
            await sync_all_products(session)
    except Exception:
        logger.exception("Failed to sync products to vector store on startup")
    try:
        with get_sync_sessionmaker()() as session:
            run_quality_score_update(session)
    except Exception:
        logger.exception("Failed to push quality scores to vector store on startup")
    start_scheduler()
    yield
    stop_scheduler()
    close_checkpointer()


def create_app() -> FastAPI:
    settings = get_settings()
    app = FastAPI(title=settings.app_name, lifespan=lifespan)
    app.include_router(health_router, prefix=settings.api_v1_prefix)
    app.include_router(chat_router, prefix=settings.api_v1_prefix)
    app.include_router(voice_router, prefix=settings.api_v1_prefix)
    app.include_router(admin_router, prefix=settings.api_v1_prefix)
    return app


app = create_app()
