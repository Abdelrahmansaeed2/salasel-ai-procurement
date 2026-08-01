import pytest
from fastapi.testclient import TestClient

from app.main import app


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
