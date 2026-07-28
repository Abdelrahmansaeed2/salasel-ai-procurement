from langchain_anthropic import ChatAnthropic
from langchain_groq import ChatGroq

from app.core.config import Settings, get_settings


def get_llm(role: str, settings: Settings | None = None) -> ChatGroq | ChatAnthropic:
    resolved = settings or get_settings()
    if resolved.llm_provider == "groq":
        kwargs: dict = {
            "model": resolved.llm_model,
            "temperature": resolved.llm_temperature,
            "timeout": None,
            "stop": None,
            "max_tokens": None,
            "reasoning_format": "parsed",
            "timeout": None,
            "max_retries": 2,
        }
        if resolved.llm_groq_api_key:
            kwargs["api_key"] = resolved.llm_groq_api_key
        return ChatGroq(**kwargs)
    kwargs = {
        "model_name": resolved.llm_model,
        "temperature": resolved.llm_temperature,
        "timeout": None,
        "stop": None,
    }
    if resolved.llm_anthropic_api_key:
        kwargs["api_key"] = resolved.llm_anthropic_api_key
    return ChatAnthropic(**kwargs)
