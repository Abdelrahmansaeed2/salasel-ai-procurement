from fastapi import FastAPI

from app.agents.checkpointer import close_checkpointer
from app.api.v1.chat import router as chat_router
from app.api.v1.health import router as health_router
from app.core.config import get_settings


def create_app() -> FastAPI:
    settings = get_settings()
    app = FastAPI(title=settings.app_name, on_shutdown=[close_checkpointer])
    app.include_router(health_router, prefix=settings.api_v1_prefix)
    app.include_router(chat_router, prefix=settings.api_v1_prefix)
    return app


app = create_app()
