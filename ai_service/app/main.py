import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.agents.checkpointer import close_checkpointer
from app.api.v1.admin import router as admin_router
from app.api.v1.chat import router as chat_router
from app.api.v1.health import router as health_router
from app.api.v1.order import router as order_router
from app.api.v1.voice import router as voice_router
from app.core.config import get_settings
from app.services.seed_service import seed_dev_data

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    settings = get_settings()
    if settings.seed_on_startup:
        try:
            await seed_dev_data()
        except Exception:
            logger.exception("Dev seed failed; continuing startup")
    yield
    close_checkpointer()


def create_app() -> FastAPI:
    settings = get_settings()
    app = FastAPI(title=settings.app_name, lifespan=lifespan)
    app.include_router(health_router, prefix=settings.api_v1_prefix)
    app.include_router(chat_router, prefix=settings.api_v1_prefix)
    app.include_router(voice_router, prefix=settings.api_v1_prefix)
    app.include_router(order_router, prefix=settings.api_v1_prefix)
    app.include_router(admin_router, prefix=settings.api_v1_prefix)
    return app


app = create_app()
