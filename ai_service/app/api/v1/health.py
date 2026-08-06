from collections.abc import Awaitable, Callable
from typing import Annotated

from fastapi import APIRouter, Depends, status
from pydantic import BaseModel

from app.core.config import Settings, get_settings

router = APIRouter(tags=["health"])

HealthChecker = Callable[[], Awaitable[bool]]


class HealthResponse(BaseModel):
    status: str
    redis: bool


async def check_redis_connection(settings: Settings) -> bool:
    from redis.asyncio import Redis

    client = Redis.from_url(
        str(settings.redis_url),
        socket_connect_timeout=settings.health_timeout_seconds,
        socket_timeout=settings.health_timeout_seconds,
    )
    try:
        return bool(await client.ping())
    finally:
        await client.aclose()


def get_redis_health_checker(
    settings: Annotated[Settings, Depends(get_settings)],
) -> HealthChecker:
    async def checker() -> bool:
        return await check_redis_connection(settings)

    return checker


@router.get("/health", response_model=HealthResponse, status_code=status.HTTP_200_OK)
async def health(
    redis_checker: Annotated[HealthChecker, Depends(get_redis_health_checker)],
) -> HealthResponse:
    redis_ok = await redis_checker()
    return HealthResponse(
        status="ok" if redis_ok else "degraded",
        redis=redis_ok,
    )
