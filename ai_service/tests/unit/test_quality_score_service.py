from app.schemas.product import SupplierQualityMetrics
from app.services.quality_score_service import compute_scores, compute_supplier_score


def test_compute_supplier_score_shrinks_low_review_count() -> None:
    score = compute_supplier_score(
        review_count=2,
        average_rating=5.0,
        on_time_delivery_rate=0.9,
        defect_rate=0.05,
        global_avg=3.0,
    )
    assert score < 5.0
    weight = 2 / 30
    expected_rating = weight * 5.0 + (1 - weight) * 3.0
    expected_score = expected_rating * 0.5 + 0.9 * 0.3 + (1 - 0.05) * 0.2
    assert score == round(expected_score, 2)


def test_compute_supplier_score_saturates_review_count() -> None:
    score = compute_supplier_score(
        review_count=100,
        average_rating=4.5,
        on_time_delivery_rate=0.95,
        defect_rate=0.02,
        global_avg=3.0,
    )
    weight = min(1.0, 100 / 30)
    expected_rating = weight * 4.5 + (1 - weight) * 3.0
    expected_score = expected_rating * 0.5 + 0.95 * 0.3 + (1 - 0.02) * 0.2
    assert score == round(expected_score, 2)


def test_compute_scores_uses_batch_global_average() -> None:
    metrics = [
        SupplierQualityMetrics(supplier_id=1, review_count=100, average_rating=4.5, on_time_delivery_rate=0.95, defect_rate=0.02),
        SupplierQualityMetrics(supplier_id=2, review_count=3, average_rating=3.5, on_time_delivery_rate=0.8, defect_rate=0.1),
    ]
    scores = compute_scores(metrics)
    assert len(scores) == 2
    assert [s[0] for s in scores] == [1, 2]
    global_avg = (4.5 + 3.5) / 2
    assert scores[0][1] == compute_supplier_score(
        review_count=100, average_rating=4.5, on_time_delivery_rate=0.95, defect_rate=0.02, global_avg=global_avg,
    )


def test_compute_scores_empty() -> None:
    assert compute_scores([]) == []
