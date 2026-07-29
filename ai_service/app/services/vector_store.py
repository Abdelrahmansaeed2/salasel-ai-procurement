from qdrant_client import QdrantClient
from qdrant_client.http.models import (
    Distance,
    PointStruct,
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
        points=[PointStruct(id=point_id, vector=vector, payload=payload)],
    )


def search(
    vector: list[float],
    filter_conditions: dict | None = None,
    limit: int = 20,
) -> list[dict]:
    client = get_client()
    ensure_collection(len(vector))
    from qdrant_client.http.models import Filter as QdrantFilter

    qdrant_filter = None
    if filter_conditions:
        qdrant_filter = QdrantFilter(**filter_conditions)

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
