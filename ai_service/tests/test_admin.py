import pytest
from fastapi.testclient import TestClient

from app.main import app


@pytest.fixture
def admin_module():
    import app.api.v1.admin as module

    return module


def test_admin_ingest_products(monkeypatch: pytest.MonkeyPatch) -> None:
    import app.api.v1.admin as admin_module

    captured: dict = {}

    async def fake_ingest(products: list) -> int:
        captured["count"] = len(products)
        return len(products)

    monkeypatch.setattr(admin_module, "ingest_products", fake_ingest)

    body = {
        "products": [
            {
                "product_id": 1,
                "supplier_id": 1,
                "product_name": "Nitrile Gloves",
                "sku": "NG",
                "category": "PPE",
                "price": 3.75,
            }
        ]
    }
    response = TestClient(app).post("/api/v1/admin/products", json=body)

    assert response.status_code == 200
    assert response.json() == {"status": "ok", "synced": 1}
    assert captured["count"] == 1


def test_admin_ingest_products_validation() -> None:
    response = TestClient(app).post("/api/v1/admin/products", json={"products": []})
    assert response.status_code == 200
    assert response.json()["synced"] == 0


def test_admin_quality_metrics(monkeypatch: pytest.MonkeyPatch) -> None:
    import app.api.v1.admin as admin_module

    captured: dict = {}

    def fake_compute(metrics: list) -> list:
        captured["metrics"] = metrics
        return [(1, 90.0)]

    def fake_update(scores: list) -> None:
        captured["scores"] = scores

    monkeypatch.setattr(admin_module, "compute_scores", fake_compute)
    monkeypatch.setattr(admin_module, "update_payloads_by_supplier", fake_update)

    body = {
        "metrics": [
            {
                "supplier_id": 1,
                "review_count": 10,
                "average_rating": 4.0,
                "on_time_delivery_rate": 0.9,
                "defect_rate": 0.05,
            }
        ]
    }
    response = TestClient(app).post("/api/v1/admin/quality-metrics", json=body)

    assert response.status_code == 200
    assert response.json() == {"status": "ok", "updated_suppliers": 1}
    assert captured["metrics"][0].supplier_id == 1
    assert captured["scores"] == [(1, 90.0)]


def test_admin_explore_products(admin_module, monkeypatch: pytest.MonkeyPatch) -> None:
    captured: dict = {}

    def fake_scroll(**kwargs) -> list:
        captured["scroll"] = kwargs
        return [{"id": 1, "product_id": "1", "product_name": "Gloves"}]

    def fake_count(**kwargs) -> int:
        captured["count"] = kwargs
        return 1

    monkeypatch.setattr(admin_module, "scroll_products", fake_scroll)
    monkeypatch.setattr(admin_module, "count_products", fake_count)

    response = TestClient(app).get(
        "/api/v1/admin/products",
        params={"category": "PPE", "supplier_id": 3, "in_stock": "true",
                "price_min": "1.0", "price_max": "50.0", "limit": 10, "offset": 5},
    )

    assert response.status_code == 200
    body = response.json()
    assert body == {
        "items": [{"id": 1, "product_id": "1", "product_name": "Gloves"}],
        "total": 1,
        "offset": 5,
        "limit": 10,
    }
    assert captured["scroll"]["category"] == "PPE"
    assert captured["scroll"]["supplier_id"] == 3
    assert captured["scroll"]["in_stock"] is True
    assert captured["scroll"]["offset"] == 5
    assert captured["count"]["category"] == "PPE"


def test_admin_explore_products_defaults(admin_module, monkeypatch: pytest.MonkeyPatch) -> None:
    captured: dict = {}

    def fake_scroll(**kwargs) -> list:
        captured.update(kwargs)
        return []

    def fake_count(**kwargs) -> int:
        return 0

    monkeypatch.setattr(admin_module, "scroll_products", fake_scroll)
    monkeypatch.setattr(admin_module, "count_products", fake_count)

    response = TestClient(app).get("/api/v1/admin/products")

    assert response.status_code == 200
    assert response.json()["offset"] == 0
    assert response.json()["limit"] == 50
    assert captured["limit"] == 50
    assert captured["with_vectors"] is False


def test_admin_explore_products_validation(admin_module) -> None:
    response = TestClient(app).get(
        "/api/v1/admin/products", params={"supplier_id": 0, "limit": 2000}
    )
    assert response.status_code == 422


def test_admin_explore_all_products(admin_module, monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(
        admin_module,
        "fetch_all_products",
        lambda: [{"id": 1, "product_name": "A"}, {"id": 2, "product_name": "B"}],
    )

    response = TestClient(app).get("/api/v1/admin/products/all")

    assert response.status_code == 200
    body = response.json()
    assert body["total"] == 2
    assert body["items"] == [{"id": 1, "product_name": "A"}, {"id": 2, "product_name": "B"}]


def test_admin_products_all_is_not_product_detail(admin_module, monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(admin_module, "fetch_all_products", lambda: [{"id": 1}])

    def fail_if_called(pid, with_vectors=False):
        raise AssertionError("get_product should not be called for /admin/products/all")

    monkeypatch.setattr(admin_module, "get_product", fail_if_called)

    response = TestClient(app).get("/api/v1/admin/products/all")

    assert response.status_code == 200
    assert response.json() == {"items": [{"id": 1}], "total": 1}


def test_admin_get_product(admin_module, monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(
        admin_module,
        "get_product",
        lambda pid, with_vectors=False: {
            "id": pid,
            "product_id": str(pid),
            "product_name": "Nitrile Gloves",
            "vector": [0.1, 0.2],
        },
    )

    response = TestClient(app).get("/api/v1/admin/products/42", params={"with_vectors": "true"})

    assert response.status_code == 200
    body = response.json()
    assert body["id"] == 42
    assert body["product_name"] == "Nitrile Gloves"
    assert body["vector"] == [0.1, 0.2]


def test_admin_get_product_missing(admin_module, monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(admin_module, "get_product", lambda pid, with_vectors=False: None)

    response = TestClient(app).get("/api/v1/admin/products/999")

    assert response.status_code == 404


def test_admin_get_product_non_int_path(admin_module) -> None:
    response = TestClient(app).get("/api/v1/admin/products/abc")
    assert response.status_code == 422


def test_admin_collection_info(admin_module, monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(
        admin_module,
        "collection_info",
        lambda: {"collection": "products", "count": 12, "dimension": 384, "distance": "Cosine"},
    )

    response = TestClient(app).get("/api/v1/admin/collection")

    assert response.status_code == 200
    assert response.json() == {
        "collection": "products",
        "count": 12,
        "dimension": 384,
        "distance": "Cosine",
    }
