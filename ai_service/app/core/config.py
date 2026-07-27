from functools import lru_cache

from pydantic import AnyUrl, Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    app_name: str = "Salasel AI Service"
    app_env: str = "local"
    api_v1_prefix: str = "/api/v1"

    database_url: str = Field(
        default=(
            "mssql+aioodbc://sa:YourStrong%21Passw0rd@localhost:1433/"
            "SalaselAiService?driver=ODBC+Driver+18+for+SQL+Server&TrustServerCertificate=yes"
        )
    )
    db_pool_size: int = 5
    db_max_overflow: int = 10
    db_command_timeout_seconds: int = 10

    redis_url: AnyUrl = Field(default="redis://localhost:6379/0")
    health_timeout_seconds: int = 3


@lru_cache
def get_settings() -> Settings:
    return Settings()
