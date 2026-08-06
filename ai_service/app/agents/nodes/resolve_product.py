import json
import logging

from langchain_core.messages import AIMessage, SystemMessage
from redis import Redis

from app.agents.state import InventoryState, ProductSpec
from app.core.config import get_settings
from app.services.embedding_service import embed_sync
from app.services.vector_store import search as vector_search

logger = logging.getLogger(__name__)


def _normalize(name: str) -> str:
    return " ".join(name.strip().lower().split())


def _is_confident_hit(resolved: list[dict], min_similarity: float) -> bool:
    top = resolved[0]
    return float(top.get("similarity_score") or 0) >= min_similarity


def _resolve_from_catalog(product_name: str, limit: int = 5) -> list[dict]:
    query_vec = embed_sync(product_name)
    return vector_search(
        query_vec,
        category=None,
        limit=limit,
    )


def resolve_product_node(state: InventoryState) -> dict:
    spec = ProductSpec.model_validate(state["spec"])
    product_name = spec.product_name
    if product_name is None or not product_name.strip():
        logger.warning("resolve_product_node called without a product_name — router/state bug")
        return {
            "messages": [AIMessage(content="What product are you looking for?")],
            "spec": spec.model_copy(update={"needs_attribute_lookup": False}),
        }

    normalized = _normalize(product_name)
    cache_key = f"resolve:{normalized}"
    redis_client = Redis.from_url(str(get_settings().redis_url))

    try:
        cached = redis_client.get(cache_key)
        if cached is not None:
            assert isinstance(cached, bytes)
            resolved = json.loads(cached.decode("utf-8"))
            logger.info("resolve cache HIT for product=%s", normalized)
        else:
            resolved = _resolve_from_catalog(product_name)
            redis_client.setex(cache_key, 3600, json.dumps(resolved))
            logger.info("resolve cache MISS for product=%s — semantic search", normalized)
    except Exception:
        logger.exception("product resolution failed for product=%s", product_name)
        return {
            "messages": [SystemMessage(content=f"I had trouble looking up {product_name!r} in our catalog.")],
            "spec": spec.model_copy(update={"needs_attribute_lookup": False}),
        }
    finally:
        redis_client.close()

    if not resolved or not _is_confident_hit(resolved, get_settings().resolve_min_similarity):
        return {
            "messages": [AIMessage(
                content=f"I couldn't find a product like {product_name!r} in our catalog. "
                        "Could you describe it differently, or tell me more about what you need?"
            )],
            "spec": spec.model_copy(update={"needs_attribute_lookup": False}),
        }

    top = resolved[0]
    payload = top.get("payload") or {}
    category = payload.get("category")

    updated = spec.model_copy(update={"needs_attribute_lookup": False})
    if category:
        updated.category = str(category)

    options = "\n".join(
        f"- {r.get('payload', {}).get('product_name', r.get('product_id'))}"
        for r in resolved
    )
    logger.info(
        "resolved product=%r -> category=%s hits=%d",
        product_name,
        updated.category,
        len(resolved),
    )
    return {
        "messages": [SystemMessage(content=f"Catalog matches for {product_name!r}:\n{options}")],
        "spec": updated,
        "resolved_candidates": resolved,
    }
