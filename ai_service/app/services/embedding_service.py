from functools import lru_cache

from fastembed import TextEmbedding

from app.core.config import get_settings


@lru_cache(maxsize=1)
def _get_model(model_name: str) -> TextEmbedding:
    return TextEmbedding(model_name=model_name)


async def embed(text: str) -> list[float]:
    model = _get_model(get_settings().embedding_model)
    for vector in model.embed(text):
        return vector.tolist()
    return []


async def embed_batch(texts: list[str]) -> list[list[float]]:
    model = _get_model(get_settings().embedding_model)
    return [v.tolist() for v in model.embed(texts)]


def embed_sync(text: str) -> list[float]:
    model = _get_model(get_settings().embedding_model)
    for vector in model.embed(text):
        return vector.tolist()
    return []


def embed_batch_sync(texts: list[str]) -> list[list[float]]:
    model = _get_model(get_settings().embedding_model)
    return [v.tolist() for v in model.embed(texts)]


def build_product_text(
    product_name: str,
    sku: str = "",
    category: str = "",
    description: str = "",
    attributes: dict[str, str] | None = None,
) -> str:
    """Build the embedding source text for a product from its descriptive fields."""
    parts = [p for p in (product_name, sku, category, description) if p]
    if attributes:
        parts.extend(f"{k}: {v}" for k, v in attributes.items() if v)
    return " ".join(parts)
