import logging
from typing import Annotated

from fastapi import APIRouter, HTTPException, Query, status

from app.schemas.product import ProductUpsertBatch, QualityMetricsBatch
from app.services.ingestion_service import ingest_products
from app.services.quality_score_service import compute_scores
from app.services.vector_store import (
    collection_info,
    count_products,
    fetch_all_products,
    get_product,
    scroll_products,
    update_payloads_by_supplier,
)

logger = logging.getLogger(__name__)
router = APIRouter(tags=["admin"])


@router.post("/admin/products")
async def admin_ingest_products(batch: ProductUpsertBatch) -> dict:
    synced = await ingest_products(batch.products)
    return {"status": "ok", "synced": synced}


@router.get("/admin/products")
async def admin_explore_products(
    category: Annotated[str | None, Query()] = None,
    supplier_id: Annotated[int | None, Query(ge=1)] = None,
    in_stock: Annotated[bool | None, Query()] = None,
    price_min: Annotated[float | None, Query(ge=0)] = None,
    price_max: Annotated[float | None, Query(ge=0)] = None,
    offset: Annotated[int, Query(ge=0)] = 0,
    limit: Annotated[int, Query(ge=1, le=1000)] = 50,
    with_vectors: Annotated[bool, Query()] = False,
) -> dict:
    items = scroll_products(
        category=category,
        supplier_id=supplier_id,
        in_stock=in_stock,
        price_min=price_min,
        price_max=price_max,
        offset=offset,
        limit=limit,
        with_vectors=with_vectors,
    )
    total = count_products(
        category=category,
        supplier_id=supplier_id,
        in_stock=in_stock,
        price_min=price_min,
        price_max=price_max,
    )
    return {"items": items, "total": total, "offset": offset, "limit": limit}


@router.get("/admin/products/all")
async def admin_explore_all_products() -> dict:
    items = fetch_all_products()
    return {"items": items, "total": len(items)}


@router.get("/admin/products/{product_id}")
async def admin_get_product(
    product_id: int,
    with_vectors: Annotated[bool, Query()] = False,
) -> dict:
    point = get_product(product_id, with_vectors=with_vectors)
    if point is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="product not found")
    return point


@router.get("/admin/collection")
async def admin_collection_info() -> dict:
    return collection_info()


@router.post("/admin/quality-metrics")
async def admin_quality_metrics(batch: QualityMetricsBatch) -> dict:
    scores = compute_scores(batch.metrics)
    update_payloads_by_supplier(scores)
    return {"status": "ok", "updated_suppliers": len(scores)}
