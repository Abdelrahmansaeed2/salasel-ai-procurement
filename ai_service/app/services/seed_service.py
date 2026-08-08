import logging

from app.schemas.product import ProductUpsert, SupplierQualityMetrics
from app.services.ingestion_service import ingest_products
from app.services.quality_score_service import compute_scores
from app.services.vector_store import (
    collection_info,
    ensure_collection,
    update_payloads_by_supplier,
)

logger = logging.getLogger(__name__)

DEFAULT_VECTOR_SIZE = 384

SEED_PRODUCTS = [
    ProductUpsert(
        product_id=1,
        supplier_id=3,
        product_name="Sugar 1kg",
        sku="SUG-1KG",
        category="Food",
        description="Fine white sugar 1kg bag.",
        attributes={"unit": "kg"},
        price=5.50,
        lat=24.7136,
        lon=46.6753,
        in_stock=True,
    ),
    ProductUpsert(
        product_id=2,
        supplier_id=3,
        product_name="Flour 1kg",
        sku="FLR-1KG",
        category="Food",
        description="All purpose flour 1kg bag.",
        attributes={"unit": "kg"},
        price=3.20,
        lat=24.7136,
        lon=46.6753,
        in_stock=True,
    ),
    ProductUpsert(
        product_id=3,
        supplier_id=4,
        product_name="Coffee Beans 500g",
        sku="COF-500G",
        category="Beverages",
        description="Premium roasted coffee beans 500g.",
        attributes={"unit": "bag"},
        price=25.00,
        lat=24.7136,
        lon=46.6753,
        in_stock=True,
    ),
    ProductUpsert(
        product_id=4,
        supplier_id=4,
        product_name="Milk 1L",
        sku="MLK-1L",
        category="Dairy",
        description="Fresh whole milk 1L carton (كرتونة لبن).",
        attributes={"unit": "bottle", "packaging": "carton"},
        price=4.00,
        lat=24.7136,
        lon=46.6753,
        in_stock=True,
    ),
]

SEED_SUPPLIER_METRICS = [
    SupplierQualityMetrics(
        supplier_id=3,
        review_count=48,
        average_rating=4.4,
        on_time_delivery_rate=0.93,
        defect_rate=0.02,
    ),
    SupplierQualityMetrics(
        supplier_id=4,
        review_count=36,
        average_rating=4.1,
        on_time_delivery_rate=0.89,
        defect_rate=0.04,
    ),
    SupplierQualityMetrics(
        supplier_id=3,
        review_count=21,
        average_rating=3.9,
        on_time_delivery_rate=0.86,
        defect_rate=0.05,
    ),
]


async def seed_dev_data() -> bool:
    """Seed a deterministic dev/test catalog into Qdrant."""
    from app.services.vector_store import get_client, _COLLECTION_NAME
    client = get_client()
    try:
        client.delete_collection(_COLLECTION_NAME)
        logger.info("Deleted existing Qdrant collection to wipe old data.")
    except Exception as e:
        logger.info(f"Could not delete collection (might not exist): {e}")
        
    ensure_collection(DEFAULT_VECTOR_SIZE)

    synced = await ingest_products(SEED_PRODUCTS)
    scores = compute_scores(SEED_SUPPLIER_METRICS)
    update_payloads_by_supplier(scores)
    logger.info("Seeded %s products (and quality scores) into Qdrant", synced)
    return True
