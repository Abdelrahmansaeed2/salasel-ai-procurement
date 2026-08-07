import logging
from typing import Any

from langchain_anthropic import ChatAnthropic
from langchain_groq import ChatGroq

from app.core.config import Settings, get_settings

logger = logging.getLogger(__name__)


def _is_json_validation_error(exc: Exception) -> bool:
    text = str(exc).lower()
    return "json_validate_failed" in text or "failed to validate json" in text


def invoke_with_json_retry(chain: Any, payload: Any, retries: int = 2) -> Any:
    """Invoke a structured-output chain, retrying transient JSON validation failures.

    Providers (e.g. Groq json_mode) intermittently return a 400
    ``json_validate_failed`` with an empty generation even for identical inputs;
    langchain's own retry only covers 429/5xx, so these are surfaced as hard
    errors. Retry a bounded number of times before propagating.
    """
    for attempt in range(retries + 1):
        try:
            return chain.invoke(payload)
        except Exception as exc:
            if attempt < retries and _is_json_validation_error(exc):
                logger.warning(
                    "LLM structured-output JSON validation failed (attempt %s/%s); retrying: %s",
                    attempt + 1, retries + 1, exc,
                )
                continue
            raise


def _build_groq(model: str, settings: Settings, role: str) -> ChatGroq:
    kwargs: dict = {
        "model": model,
        "temperature": settings.llm_temperature if role == "conversation" else settings.llm_formatting_temperature,
        "timeout": settings.llm_timeout,
        "stop": None,
        "max_tokens": settings.llm_max_tokens,
        "max_retries": 2,
    }
    api_key = settings.llm_groq_api_key
    if api_key:
        kwargs["api_key"] = api_key
    return ChatGroq(**kwargs)


def _build_anthropic(model: str, settings: Settings, role: str) -> ChatAnthropic:
    kwargs: dict = {
        "model_name": model,
        "temperature": settings.llm_temperature if role == "conversation" else settings.llm_formatting_temperature,
        "timeout": settings.llm_timeout,
        "stop": None,
    }
    api_key = settings.llm_anthropic_api_key
    if api_key:
        kwargs["api_key"] = api_key
    return ChatAnthropic(**kwargs)


def get_llm(role: str = "conversation", settings: Settings | None = None) -> ChatGroq | ChatAnthropic:
    resolved = settings or get_settings()

    if role == "formatting":
        provider = resolved.llm_formatting_provider
        model = resolved.llm_formatting_model
    else:
        provider = resolved.llm_provider
        model = resolved.llm_model

    if provider == "groq":
        return _build_groq(model, resolved, role)
    return _build_anthropic(model, resolved, role)
