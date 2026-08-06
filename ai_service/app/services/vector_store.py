from qdrant_client import QdrantClient
from qdrant_client.http.models import (
    Distance,
    FieldCondition,
    Filter,
    GeoPoint,
    GeoRadius,
    MatchExcept,
    MatchValue,
    PointStruct,
    Range,
    VectorParams,
)

from app.core.config import get_settings

_COLLECTION_NAME = "products"


def get_client() -> QdrantClient:
    return QdrantClient(url=str(get_settings().qdrant_url))


def ensure_collection(vector_size: int = 384) -> None:
    client = get_client()
    collections = client.get_collections().collections
    if not any(c.name == _COLLECTION_NAME for c in collections):
        client.create_collection(
            collection_name=_COLLECTION_NAME,
            vectors_config=VectorParams(size=vector_size, distance=Distance.COSINE),
        )


def upsert(point_id: str, vector: list[float], payload: dict) -> None:
    client = get_client()
    ensure_collection(len(vector))
    client.upsert(
        collection_name=_COLLECTION_NAME,
        points=[PointStruct(id=int(point_id), vector=vector, payload=payload)],
    )


def update_payloads(updates: list[tuple[str, dict]]) -> None:
    if not updates:
        return
    client = get_client()
    for pid, payload in updates:
        client.set_payload(
            collection_name=_COLLECTION_NAME,
            payload=payload,
            points=[int(pid)],
        )


def list_by_category(category: str, *, in_stock_only: bool = True, limit: int = 50) -> list[dict]:
    """Return product payloads in a category (no vectors) for RAG attribute lookup."""
    client = get_client()
    conditions = [FieldCondition(key="category", match=MatchValue(value=category))]
    if in_stock_only:
        conditions.append(FieldCondition(key="in_stock", match=MatchValue(value=True)))
    points, _ = client.scroll(
        collection_name=_COLLECTION_NAME,
        scroll_filter=Filter(must=conditions),
        limit=limit,
        with_payload=True,
        with_vectors=False,
    )
    return [p.payload or {} for p in points]


def build_explore_filter(
    *,
    category: str | None = None,
    supplier_id: int | None = None,
    in_stock: bool | None = None,
    price_min: float | None = None,
    price_max: float | None = None,
) -> Filter | None:
    """Build a payload filter for admin browsing; None when no constraints given."""
    conditions: list[FieldCondition] = []

    if category is not None:
        conditions.append(FieldCondition(key="category", match=MatchValue(value=category)))

    if supplier_id is not None:
        conditions.append(FieldCondition(
            key="supplier_id",
            match=MatchValue(value=str(supplier_id)),
        ))

    if in_stock is not None:
        conditions.append(FieldCondition(key="in_stock", match=MatchValue(value=in_stock)))

    if price_min is not None or price_max is not None:
        conditions.append(FieldCondition(
            key="price",
            range=Range(
                gte=price_min if price_min is not None else None,
                lte=price_max if price_max is not None else None,
            ),
        ))

    return Filter(must=conditions) if conditions else None


def scroll_products(
    *,
    category: str | None = None,
    supplier_id: int | None = None,
    in_stock: bool | None = None,
    price_min: float | None = None,
    price_max: float | None = None,
    offset: int = 0,
    limit: int = 50,
    with_vectors: bool = False,
) -> list[dict]:
    """Scroll product points (payload + optional vector) for admin browsing."""
    client = get_client()
    qdrant_filter = build_explore_filter(
        category=category,
        supplier_id=supplier_id,
        in_stock=in_stock,
        price_min=price_min,
        price_max=price_max,
    )
    points, _ = client.scroll(
        collection_name=_COLLECTION_NAME,
        scroll_filter=qdrant_filter,
        offset=offset if offset else None,
        limit=limit,
        with_payload=True,
        with_vectors=with_vectors,
    )
    return [_point_record(p, with_vectors) for p in points]


def count_products(
    *,
    category: str | None = None,
    supplier_id: int | None = None,
    in_stock: bool | None = None,
    price_min: float | None = None,
    price_max: float | None = None,
) -> int:
    """Count product points matching the filter; excludes collection drop by default."""
    client = get_client()
    qdrant_filter = build_explore_filter(
        category=category,
        supplier_id=supplier_id,
        in_stock=in_stock,
        price_min=price_min,
        price_max=price_max,
    )
    return client.count(
        collection_name=_COLLECTION_NAME,
        count_filter=qdrant_filter,
        exact=True,
    ).count


def get_product(point_id: int, *, with_vectors: bool = False) -> dict | None:
    client = get_client()
    records = client.retrieve(
        collection_name=_COLLECTION_NAME,
        ids=[point_id],
        with_payload=True,
        with_vectors=with_vectors,
    )
    if not records:
        return None
    return _point_record(records[0], with_vectors)


def collection_info() -> dict:
    client = get_client()
    info = client.get_collection(collection_name=_COLLECTION_NAME)
    count = client.count(collection_name=_COLLECTION_NAME, exact=False).count
    return {
        "collection": _COLLECTION_NAME,
        "count": count,
        "dimension": info.config.params.vectors.size,
        "distance": str(info.config.params.vectors.distance),
    }


def _point_record(point, with_vectors: bool) -> dict:
    record = {"id": point.id, **((point.payload) or {})}
    if with_vectors:
        vector = point.vector
        record["vector"] = vector if isinstance(vector, list) else list(vector)
    return record


def update_payloads_by_supplier(scores: list[tuple[int, float]]) -> None:
    """Push payload-only quality_score updates to every product of each supplier."""
    if not scores:
        return
    client = get_client()
    for supplier_id, score in scores:
        points, _ = client.scroll(
            collection_name=_COLLECTION_NAME,
            scroll_filter=Filter(must=[
                FieldCondition(key="supplier_id", match=MatchValue(value=str(supplier_id))),
            ]),
            limit=10_000,
            with_payload=False,
            with_vectors=False,
        )
        ids = [p.id for p in points]
        if ids:
            client.set_payload(
                collection_name=_COLLECTION_NAME,
                payload={"quality_score": score},
                points=ids,
            )


def search(
    vector: list[float],
    *,
    category: str | None = None,
    price_min: float | None = None,
    price_max: float | None = None,
    geo_center: tuple[float, float] | None = None,
    geo_radius_km: float | None = None,
    quality_min: float | None = None,
    excluded_ids: list[str] | None = None,
    limit: int = 20,
) -> list[dict]:
    client = get_client()
    ensure_collection(len(vector))

    conditions: list[FieldCondition] = []

    if category is not None:
        conditions.append(FieldCondition(
            key="category",
            match=MatchValue(value=category),
        ))

    if price_min is not None or price_max is not None:
        conditions.append(FieldCondition(
            key="price",
            range=Range(
                gte=price_min if price_min is not None else None,
                lte=price_max if price_max is not None else None,
            ),
        ))

    if geo_center is not None and geo_radius_km is not None:
        conditions.append(FieldCondition(
            key="geo",
            geo_radius=GeoRadius(
                center=GeoPoint(lat=geo_center[0], lon=geo_center[1]),
                radius=int(geo_radius_km * 1000),
            ),
        ))

    if quality_min is not None:
        conditions.append(FieldCondition(
            key="quality_score",
            range=Range(gte=quality_min),
        ))

    if excluded_ids:
        conditions.append(FieldCondition(
            key="product_id",
            match=MatchExcept(**{"except": excluded_ids}),
        ))

    qdrant_filter = Filter(must=conditions) if conditions else None

    results = client.query_points(
        collection_name=_COLLECTION_NAME,
        query=vector,
        query_filter=qdrant_filter,
        limit=limit,
    ).points
    return [
        {
            "product_id": (hit.payload or {}).get("product_id"),
            "supplier_id": (hit.payload or {}).get("supplier_id"),
            "similarity_score": hit.score,
            "payload": hit.payload or {},
        }
        for hit in results
    ]
