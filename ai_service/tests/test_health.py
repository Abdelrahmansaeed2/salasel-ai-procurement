from collections.abc import Awaitable, Callable

from fastapi.testclient import TestClient

from app.api.v1.health import get_database_health_checker, get_redis_health_checker
from app.main import app

HealthChecker = Callable[[], Awaitable[bool]]


def override_health_checker(value: bool) -> HealthChecker:
    async def checker() -> bool:
        return value

    return checker


def test_health_returns_ok_when_db_and_redis_are_reachable() -> None:
    app.dependency_overrides[get_database_health_checker] = lambda: override_health_checker(True)
    app.dependency_overrides[get_redis_health_checker] = lambda: override_health_checker(True)

    try:
        response = TestClient(app).get("/api/v1/health")
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 200
    assert response.json() == {"status": "ok", "database": True, "redis": True}


def test_health_returns_degraded_when_dependency_is_unreachable() -> None:
    app.dependency_overrides[get_database_health_checker] = lambda: override_health_checker(True)
    app.dependency_overrides[get_redis_health_checker] = lambda: override_health_checker(False)

    try:
        response = TestClient(app).get("/api/v1/health")
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 200
    assert response.json() == {"status": "degraded", "database": True, "redis": False}
