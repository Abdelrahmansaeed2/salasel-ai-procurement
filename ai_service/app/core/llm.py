from langchain_anthropic import ChatAnthropic
from langchain_groq import ChatGroq

from app.core.config import Settings, get_settings


def _build_groq(model: str, settings: Settings, role: str) -> ChatGroq:
    kwargs: dict = {
        "model": model,
        "temperature": settings.llm_temperature if role == "conversation" else settings.llm_formatting_temperature,
        "timeout": settings.llm_timeout,
        "stop": None,
        "max_tokens": None,
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
