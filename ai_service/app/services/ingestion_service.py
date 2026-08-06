import logging

from app.schemas.product import ProductUpsert
from app.services.embedding_service import build_product_text, embed
from app.services.vector_store import upsert as vector_upsert

logger = logging.getLogger(__name__)


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
