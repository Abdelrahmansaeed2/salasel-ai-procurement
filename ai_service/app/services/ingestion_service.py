import logging

from app.schemas.product import ProductUpsert
from app.services.embedding_service import build_product_text, embed
from app.services.vector_store import get_product, update_payloads
from app.services.vector_store import upsert as vector_upsert

logger = logging.getLogger(__name__)

_TEXT_FIELDS = ("product_name", "sku", "category", "description", "attributes")


def product_payload(product: ProductUpsert) -> dict:
    return {
        "product_id": str(product.product_id),
        "supplier_id": str(product.supplier_id),
        "product_name": product.product_name,
        "sku": product.sku,
        "category": product.category,
        "description": product.description,
        "attributes": product.attributes,
        "price": float(product.price),
        "geo": {"lat": float(product.lat), "lon": float(product.lon)},
        "quality_score": None,
        "in_stock": bool(product.in_stock),
    }


async def ingest_products(products: list[ProductUpsert]) -> int:
    """Embed and upsert a batch of products into the vector store.

    Idempotent by product_id — re-ingesting overwrites the same point.
    quality_score is left null; the quality-metrics endpoint fills it in
    payload-only (no re-embed).
    """
    for product in products:
        text = build_product_text(
            product.product_name,
            product.sku,
            product.category,
            product.description,
            product.attributes,
        )
        vector = await embed(text)
        vector_upsert(
            point_id=str(product.product_id),
            vector=vector,
            payload=product_payload(product),
        )
        logger.info("Ingested product %s to vector store", product.product_id)
    return len(products)


async def update_product(product_id: int, product: ProductUpsert) -> dict | None:
    """Update a single product in the vector store.

    Returns None when the product doesn't exist (update-only, not upsert).
    Re-embeds and overwrites the point only when a descriptive field changed;
    price/geo/stock/supplier-only changes go through a payload-only set_payload
    (no embedding). quality_score is preserved either way.
    """
    existing = get_product(int(product_id))
    if existing is None:
        return None

    payload = product_payload(product)
    payload["quality_score"] = existing.get("quality_score")

    needs_embed = any(
        existing.get(field) != getattr(product, field)
        for field in _TEXT_FIELDS
    )
    if needs_embed:
        text = build_product_text(
            product.product_name,
            product.sku,
            product.category,
            product.description,
            product.attributes,
        )
        vector = await embed(text)
        vector_upsert(
            point_id=str(product_id),
            vector=vector,
            payload=payload,
        )
        logger.info("Updated product %s to vector store (re-embedded)", product_id)
    else:
        update_payloads([(str(product_id), payload)])
        logger.info("Updated product %s payload only (no re-embed)", product_id)
    return {"re_embedded": needs_embed}
