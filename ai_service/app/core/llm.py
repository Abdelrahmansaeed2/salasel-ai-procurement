from langchain_anthropic import ChatAnthropic
from langchain_google_genai import ChatGoogleGenerativeAI

from app.core.config import Settings, get_settings


def _build_gemini(model: str, settings: Settings, role: str) -> ChatGoogleGenerativeAI:
    """Build a Google Gemini chat model."""
    kwargs: dict[str, Any] = {
        "model": model,
        "temperature": settings.llm_temperature if role == "conversation" else settings.llm_formatting_temperature,
    }

    api_key = settings.llm_gemini_api_key
    if api_key:
        kwargs["api_key"] = api_key

    return ChatGoogleGenerativeAI(**kwargs)


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


def get_llm(role: str = "conversation", settings: Settings | None = None) -> ChatGoogleGenerativeAI | ChatAnthropic:
    resolved = settings or get_settings()

    if role == "formatting":
        provider = resolved.llm_formatting_provider
        model = resolved.llm_formatting_model
    else:
        provider = resolved.llm_provider
        model = resolved.llm_model

    if provider == "gemini":
        return _build_gemini(model, resolved, role)
    return _build_anthropic(model, resolved, role)
