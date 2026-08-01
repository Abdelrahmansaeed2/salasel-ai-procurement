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
