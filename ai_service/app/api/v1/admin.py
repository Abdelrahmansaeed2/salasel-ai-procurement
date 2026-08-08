import logging
from typing import Annotated

from fastapi import APIRouter, HTTPException, Query, status, Form, File, UploadFile

from app.schemas.product import ProductUpsert, ProductUpsertBatch, QualityMetricsBatch
from app.services.ingestion_service import ingest_products, update_product
from app.services.quality_score_service import compute_scores
from app.services.vector_store import (
    collection_info,
    count_products,
    fetch_all_products,
    get_product,
    scroll_products,
    update_payloads_by_supplier,
)
from app.services.vector_store import (
    delete_product as delete_product_point,
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


@router.put("/admin/products/{product_id}")
async def admin_update_product(product_id: int, product: ProductUpsert) -> dict:
    if product.product_id != product_id:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail="product_id in body must match the URL",
        )
    result = await update_product(product_id, product)
    if result is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="product not found")
    return {"status": "ok", "product_id": product_id, **result}


@router.delete("/admin/products/{product_id}")
async def admin_delete_product(product_id: int) -> dict:
    if get_product(product_id) is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="product not found")
    delete_product_point(product_id)
    return {"status": "ok", "product_id": product_id}


@router.get("/admin/collection")
async def admin_collection_info() -> dict:
    return collection_info()


@router.post("/admin/quality-metrics")
async def admin_quality_metrics(batch: QualityMetricsBatch) -> dict:
    scores = compute_scores(batch.metrics)
    update_payloads_by_supplier(scores)
    return {"status": "ok", "updated_suppliers": len(scores)}


@router.post("/admin/knowledge/ingest")
async def admin_knowledge_ingest(
    supplier_id: Annotated[int, Form(...)],
    file: Annotated[UploadFile, File(...)],
    lat: Annotated[float, Form(...)] = 24.7136,
    lon: Annotated[float, Form(...)] = 46.6753,
) -> dict:
    if not file.filename:
        raise HTTPException(status_code=400, detail="No file name")
        
    ext = file.filename.lower().split('.')[-1]
    
    if ext == "csv":
        import csv
        import io
        import uuid
        
        content = await file.read()
        text = content.decode("utf-8-sig")
        reader = csv.DictReader(io.StringIO(text))
        
        products = []
        for row in reader:
            # Map standard columns: Product_Name, SKU, Category, Description, Unit, Price, In_Stock
            # Generate a stable product_id or random one since it's just a demo seed
            pid = hash(f"{supplier_id}_{row.get('SKU', '')}") % (10 ** 8)
            
            in_stock_str = str(row.get("In_Stock", "True")).lower()
            in_stock = in_stock_str in ["true", "1", "yes"]
            
            p = ProductUpsert(
                product_id=pid,
                supplier_id=supplier_id,
                product_name=row.get("Product_Name", ""),
                sku=row.get("SKU", ""),
                category=row.get("Category", ""),
                description=row.get("Description", ""),
                attributes={"unit": row.get("Unit", "")},
                price=float(row.get("Price", 0) or 0),
                lat=lat,
                lon=lon,
                in_stock=in_stock,
            )
            products.append(p)
            
        synced = await ingest_products(products)
        return {"status": "ok", "message": f"Ingested {synced} products from CSV"}
        
    else:
        # For PDF / XLSX, simulate chunking and ingestion for the UI
        return {"status": "ok", "message": f"Simulated ingestion for {ext} file"}
