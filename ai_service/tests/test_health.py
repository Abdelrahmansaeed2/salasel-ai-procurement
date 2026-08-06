from collections.abc import Awaitable, Callable

from fastapi.testclient import TestClient

from app.api.v1.health import get_redis_health_checker
from app.main import app

HealthChecker = Callable[[], Awaitable[bool]]


def override_health_checker(value: bool) -> HealthChecker:
    async def checker() -> bool:
        return value

    return checker


def test_health_returns_ok_when_redis_is_reachable() -> None:
    app.dependency_overrides[get_redis_health_checker] = lambda: override_health_checker(True)

    try:
        response = TestClient(app).get("/api/v1/health")
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 200
    assert response.json() == {"status": "ok", "redis": True}


def test_health_returns_degraded_when_redis_is_unreachable() -> None:
    app.dependency_overrides[get_redis_health_checker] = lambda: override_health_checker(False)

    try:
        response = TestClient(app).get("/api/v1/health")
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 200
    assert response.json() == {"status": "degraded", "redis": False}
