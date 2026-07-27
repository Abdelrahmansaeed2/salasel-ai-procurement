from app.core.config import Settings


def test_settings_have_sprint1_defaults() -> None:
    settings = Settings()

    assert settings.app_name == "Salasel AI Service"
    assert settings.api_v1_prefix == "/api/v1"
    assert settings.db_pool_size == 5
    assert settings.db_max_overflow == 10
    assert str(settings.redis_url).startswith("redis://")
