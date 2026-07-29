import json
import logging

from langchain_core.messages import SystemMessage
from redis import Redis

from app.agents.state import InventoryState, ProductSpec
from app.core.config import get_settings
from app.db.session import get_sync_sessionmaker
from app.repositories.product_repository import ProductRepository

logger = logging.getLogger(__name__)


def rag_lookup_node(state: InventoryState) -> dict:
    spec = ProductSpec.model_validate(state["spec"])
    category = spec.category
    if category is None:
        logger.warning("rag_lookup_node called with category=None — this indicates a router/state bug")
        return {
            "messages": [SystemMessage(content="I need to know what category you're looking for.")],
            "spec": spec.model_copy(update={"needs_attribute_lookup": False}),
        }

    cache_key = f"attrs:{category}"
    redis_client = Redis.from_url(str(get_settings().redis_url))

    try:
        cached = redis_client.get(cache_key)
        if cached is not None:
            assert isinstance(cached, bytes)
            attrs = json.loads(cached.decode("utf-8"))
            logger.info("RAG cache HIT for category=%s", category)
        else:
            session = get_sync_sessionmaker()()
            try:
                repo = ProductRepository(session)
                attrs = repo.get_distinct_attributes_sync(category)
            finally:
                session.close()
            redis_client.setex(cache_key, 3600, json.dumps(attrs))
            logger.info("RAG cache MISS for category=%s — queried DB", category)
    except Exception:
        logger.exception("RAG lookup failed for category=%s", category)
        return {
            "messages": [SystemMessage(content=f"I found some options in the {category} category.")],
            "spec": spec.model_copy(update={"needs_attribute_lookup": False}),
        }
    finally:
        redis_client.close()

    attr_text = "\n".join(f"- {a}" for a in attrs)
    return {
        "messages": [SystemMessage(content=f"Available products in {category}:\n{attr_text}")],
        "spec": spec.model_copy(update={"needs_attribute_lookup": False}),
    }
