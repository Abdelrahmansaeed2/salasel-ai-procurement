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
    seed_on_startup: bool = True

    redis_url: AnyUrl = Field(default="redis://localhost:6379/0")
    health_timeout_seconds: int = 3

    llm_provider: str = "groq"
    llm_model: str = "llama-3.3-70b-versatile"
    llm_groq_api_key: str = ""
    llm_anthropic_api_key: str = ""
    llm_temperature: float = 0.0
    llm_timeout: int = 30
    llm_max_tokens: int = 4096

    llm_formatting_provider: str = "groq"
    llm_formatting_model: str = "llama-3.1-8b-instant"
    llm_formatting_temperature: float = 0.0

    stt_provider: str = "groq"
    stt_model: str = "whisper-large-v3-turbo"
    stt_api_key: str = ""
    stt_timeout: int = 60
    stt_language: str = ""
    stt_max_audio_bytes: int = 25 * 1024 * 1024

    qdrant_url: AnyUrl = Field(default="http://localhost:6333")
    embedding_model: str = "BAAI/bge-small-en-v1.5"
    resolve_min_similarity: float = 0.6

    default_radius_km: int = 50
    default_quality_threshold: float = 0.0
    rank_weight_similarity: float = 1.0
    rank_weight_quality: float = 0.7
    rank_weight_distance: float = 0.5


@lru_cache
def get_settings() -> Settings:
    return Settings()
