from app.agents.state import Candidate
from app.services.ranking_service import blend_and_rank, haversine_km


def test_blend_and_rank_orders_by_blended_score() -> None:
    location = (0.0, 0.0)

    candidates = [
        {"product_id": "A1", "similarity_score": 0.95, "payload": {"supplier_id": "S1", "quality_score": 0.9, "geo": {"lat": 0.0, "lon": 0.05}, "price": 150.0}},
        {"product_id": "A2", "similarity_score": 0.90, "payload": {"supplier_id": "S1", "quality_score": 0.8, "geo": {"lat": 0.0, "lon": 0.05}, "price": 200.0}},
        {"product_id": "A3", "similarity_score": 0.85, "payload": {"supplier_id": "S1", "quality_score": 0.95, "geo": {"lat": 0.0, "lon": 0.05}, "price": 175.0}},
        {"product_id": "B1", "similarity_score": 0.80, "payload": {"supplier_id": "S2", "quality_score": 0.7, "geo": {"lat": 0.0, "lon": 50.0}, "price": 100.0}},
        {"product_id": "B2", "similarity_score": 0.75, "payload": {"supplier_id": "S2", "quality_score": 0.85, "geo": {"lat": 0.0, "lon": 50.0}, "price": 120.0}},
        {"product_id": "C1", "similarity_score": 0.70, "payload": {"supplier_id": "S3", "quality_score": 0.6, "geo": None, "price": 90.0}},
        {"product_id": "D1", "similarity_score": 0.65, "payload": {"supplier_id": "S4", "quality_score": 0.5, "geo": {"lat": 0.0, "lon": -0.05}, "price": 80.0}},
    ]

    weights = {"sim": 1.0, "quality": 0.7, "distance": 0.5}
    result = blend_and_rank(candidates, weights, location, radius_km=50.0)

    assert len(result) == 5
    assert result[0].product_id == "A1"
    assert result[1].product_id == "A3"
    assert result[2].product_id == "A2"
    assert result[3].product_id == "D1"
    assert result[4].product_id == "C1"

    for r in result:
        assert isinstance(r, Candidate)

    assert result[0].similarity_score == 0.95
    assert result[0].quality_score == 0.9


def test_blend_and_rank_respects_top5_truncation() -> None:
    location = (0.0, 0.0)
    many_candidates = [
        {"product_id": f"P{i}", "similarity_score": 1.0 - i * 0.01,
         "payload": {"supplier_id": "S1", "quality_score": 0.5, "geo": {"lat": 0.0, "lon": 0.01}, "price": 100.0}}
        for i in range(10)
    ]
    result = blend_and_rank(many_candidates, {"sim": 1.0, "quality": 0.0, "distance": 0.0}, location)
    assert len(result) == 5


def test_haversine_km_known_value() -> None:
    distance = haversine_km(40.7128, -74.0060, 40.7580, -73.9855)
    assert 4.0 < distance < 6.0


def test_haversine_km_zero() -> None:
    assert haversine_km(0.0, 0.0, 0.0, 0.0) == 0.0


def test_blend_and_rank_candidate_fields() -> None:
    location = (0.0, 0.0)
    candidates = [
        {"product_id": "X1", "similarity_score": 0.9,
         "payload": {"supplier_id": "S1", "quality_score": 0.8, "geo": {"lat": 0.0, "lon": 0.01}, "price": 99.99}},
    ]
    result = blend_and_rank(candidates, {"sim": 1.0, "quality": 1.0, "distance": 0.0}, location)
    assert len(result) == 1
    c = result[0]
    assert c.product_id == "X1"
    assert c.supplier_id == "S1"
    assert c.similarity_score == 0.9
    assert c.quality_score == 0.8
    assert c.distance_km > 0
    assert c.price == 99.99


def test_blend_and_rank_copies_product_metadata_from_payload() -> None:
    location = (0.0, 0.0)
    candidates = [
        {"product_id": "X1", "similarity_score": 0.9,
         "payload": {
             "supplier_id": "S1",
             "quality_score": 0.8,
             "geo": {"lat": 0.0, "lon": 0.01},
             "price": 99.99,
             "product_name": "Nitrile Gloves Large",
             "sku": "PPE-GLOVES-NITRILE-L",
             "category": "PPE",
             "description": "Powder-free disposable exam gloves, latex-free.",
             "attributes": {"size": "L", "material": "nitrile"},
             "in_stock": True,
         }},
        # A candidate without metadata fields -> defaults are kept
        {"product_id": "Y2", "similarity_score": 0.8,
         "payload": {"supplier_id": "S2", "quality_score": 0.6, "geo": None, "price": 10.0}},
    ]
    result = blend_and_rank(candidates, {"sim": 1.0, "quality": 1.0, "distance": 0.0}, location)
    c = next(x for x in result if x.product_id == "X1")
    assert c.product_name == "Nitrile Gloves Large"
    assert c.sku == "PPE-GLOVES-NITRILE-L"
    assert c.category == "PPE"
    assert "latex-free" in c.description
    assert c.attributes == {"size": "L", "material": "nitrile"}
    assert c.in_stock is True

    c2 = next(x for x in result if x.product_id == "Y2")
    assert c2.product_name is None
    assert c2.attributes == {}
    assert c2.in_stock is None
