import json
import logging

from langchain_core.messages import SystemMessage
from redis import Redis

from app.agents.state import InventoryState, ProductSpec
from app.core.config import get_settings
from app.services.vector_store import list_by_category

logger = logging.getLogger(__name__)


def _format_attrs(products: list[dict], category: str) -> list[str]:
    if not products:
        return [f"No products found for category: {category}"]
    attrs: list[str] = []
    for p in products:
        name = p.get("product_name", "")
        sku = p.get("sku", "")
        price = float(p.get("price") or 0)
        attrs.append(f"{name} (SKU: {sku}, ${price:.2f})")
    return attrs


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
            products = list_by_category(category, in_stock_only=True)
            attrs = _format_attrs(products, category)
            redis_client.setex(cache_key, 3600, json.dumps(attrs))
            logger.info("RAG cache MISS for category=%s — queried Qdrant payload", category)
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
