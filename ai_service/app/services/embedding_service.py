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
