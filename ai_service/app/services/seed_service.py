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
        supplier_id=1,
        product_name="Nitrile Gloves Large",
        sku="PPE-GLOVES-NITRILE-L",
        category="PPE",
        description="Powder-free disposable exam gloves, latex-free.",
        attributes={"size": "L", "material": "nitrile"},
        price=4.50,
        lat=30.0444,
        lon=31.2357,
        in_stock=True,
    ),
    ProductUpsert(
        product_id=2,
        supplier_id=1,
        product_name="Nitrile Gloves Medium",
        sku="PPE-GLOVES-NITRILE-M",
        category="PPE",
        description="Powder-free disposable exam gloves, latex-free.",
        attributes={"size": "M", "material": "nitrile"},
        price=3.75,
        lat=30.0444,
        lon=31.2357,
        in_stock=True,
    ),
    ProductUpsert(
        product_id=3,
        supplier_id=1,
        product_name="Nitrile Gloves Small",
        sku="PPE-GLOVES-NITRILE-S",
        category="PPE",
        description="Powder-free disposable exam gloves, latex-free.",
        attributes={"size": "S", "material": "nitrile"},
        price=3.50,
        lat=30.0444,
        lon=31.2357,
        in_stock=True,
    ),
    ProductUpsert(
        product_id=4,
        supplier_id=2,
        product_name="KN95 Respirator Masks",
        sku="PPE-MASKS-KN95",
        category="PPE",
        description="Box of 50 KN95 particulate respirator masks, five-layer.",
        attributes={"size": "One Size", "count": "50"},
        price=18.90,
        lat=31.2001,
        lon=29.9187,
        in_stock=True,
    ),
    ProductUpsert(
        product_id=5,
        supplier_id=2,
        product_name="Safety Goggles",
        sku="PPE-GOGGLES",
        category="PPE",
        description="Anti-fog chemical splash goggles, indirect ventilation.",
        attributes={"size": "One Size", "lens": "clear"},
        price=6.25,
        lat=31.2001,
        lon=29.9187,
        in_stock=True,
    ),
    ProductUpsert(
        product_id=6,
        supplier_id=2,
        product_name="Disposable Face Shields",
        sku="PPE-SHIELDS",
        category="PPE",
        description="Full-face transparent shields, single-use.",
        attributes={"size": "One Size"},
        price=8.40,
        lat=31.2001,
        lon=29.9187,
        in_stock=False,
    ),
    ProductUpsert(
        product_id=7,
        supplier_id=3,
        product_name="Heavy-Duty Cleaning Gloves",
        sku="JAN-GLOVES-HD",
        category="janitorial",
        description="Reusable rubber gloves, chemical resistant.",
        attributes={"size": "M", "material": "rubber"},
        price=5.10,
        lat=30.0131,
        lon=31.2089,
        in_stock=True,
    ),
    ProductUpsert(
        product_id=8,
        supplier_id=3,
        product_name="Disinfectant Wipes",
        sku="JAN-WIPES-DISINFECTANT",
        category="janitorial",
        description="Bucket of 150 hospital-grade disinfectant wipes.",
        attributes={"count": "150", "scent": "unscented"},
        price=11.75,
        lat=30.0131,
        lon=31.2089,
        in_stock=True,
    ),
    ProductUpsert(
        product_id=9,
        supplier_id=3,
        product_name="All-Purpose Cleaner",
        sku="JAN-CLEANER-5L",
        category="janitorial",
        description="5L concentrated multi-surface cleaner.",
        attributes={"volume_l": "5"},
        price=9.30,
        lat=30.0131,
        lon=31.2089,
        in_stock=True,
    ),
    ProductUpsert(
        product_id=10,
        supplier_id=3,
        product_name="Microfiber Mop Head",
        sku="JAN-MOP-MICROFIBER",
        category="janitorial",
        description="Washable microfiber flat mop head.",
        attributes={"size": "40cm"},
        price=7.85,
        lat=30.0131,
        lon=31.2089,
        in_stock=False,
    ),
]

SEED_SUPPLIER_METRICS = [
    SupplierQualityMetrics(
        supplier_id=1,
        review_count=48,
        average_rating=4.4,
        on_time_delivery_rate=0.93,
        defect_rate=0.02,
    ),
    SupplierQualityMetrics(
        supplier_id=2,
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
    """Seed a deterministic dev/test catalog into Qdrant.

    No-op (returns False) when the collection already has points, so it never
    clobbers data the backend pushed. Returns True when a fresh seed ran.
    """
    ensure_collection(DEFAULT_VECTOR_SIZE)
    existing = collection_info()["count"]
    if existing > 0:
        logger.info("Qdrant already has %s points; skipping dev seed", existing)
        return False

    synced = await ingest_products(SEED_PRODUCTS)
    scores = compute_scores(SEED_SUPPLIER_METRICS)
    update_payloads_by_supplier(scores)
    logger.info("Seeded %s products (and quality scores) into Qdrant", synced)
    return True
