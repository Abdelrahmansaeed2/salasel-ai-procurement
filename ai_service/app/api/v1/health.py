from collections.abc import Awaitable, Callable
from typing import Annotated

from fastapi import APIRouter, Depends, status
from pydantic import BaseModel

from app.core.config import Settings, get_settings
from app.db.session import check_database_connection

router = APIRouter(tags=["health"])

HealthChecker = Callable[[], Awaitable[bool]]


class HealthResponse(BaseModel):
    status: str
    database: bool
    redis: bool


async def check_redis_connection(settings: Settings) -> bool:
    from redis.asyncio import Redis

    client = Redis.from_url(
        str(settings.redis_url),
        socket_connect_timeout=settings.health_timeout_seconds,
        socket_timeout=settings.health_timeout_seconds,
    )
    try:
        return bool( client.ping())
    finally:
        await client.aclose()


def get_database_health_checker(
    settings: Annotated[Settings, Depends(get_settings)],
) -> HealthChecker:
    async def checker() -> bool:
        return await check_database_connection(settings)

    return checker


def get_redis_health_checker(
    settings: Annotated[Settings, Depends(get_settings)],
) -> HealthChecker:
    async def checker() -> bool:
        return await check_redis_connection(settings)

    return checker


@router.get("/health", response_model=HealthResponse, status_code=status.HTTP_200_OK)
async def health(
    database_checker: Annotated[HealthChecker, Depends(get_database_health_checker)],
    redis_checker: Annotated[HealthChecker, Depends(get_redis_health_checker)],
) -> HealthResponse:
    database_ok = await database_checker()
    redis_ok = await redis_checker()
    service_ok = database_ok and redis_ok
    return HealthResponse(
        status="ok" if service_ok else "degraded",
        database=database_ok,
        redis=redis_ok,
    )
