from decimal import Decimal
from unittest.mock import MagicMock, patch

from app.services.quality_score_job import _compute_score, compute_quality_scores


class FakeQualityScore:
    def __init__(self, supplier_id: int, review_count: int, average_rating: float,
                 on_time_delivery_rate: float, defect_rate: float):
        self.supplier_id = supplier_id
        self.review_count = review_count
        self.average_rating = Decimal(str(average_rating))
        self.on_time_delivery_rate = Decimal(str(on_time_delivery_rate))
        self.defect_rate = Decimal(str(defect_rate))


def test_compute_score_shrinks_low_review_count() -> None:
    row = FakeQualityScore(1, review_count=2, average_rating=5.0, on_time_delivery_rate=0.9, defect_rate=0.05)
    global_avg = 3.0
    score = _compute_score(row, global_avg)

    assert score < 5.0
    weight = 2 / 30
    expected_rating = weight * 5.0 + (1 - weight) * 3.0
    expected_score = expected_rating * 0.5 + 0.9 * 0.3 + (1 - 0.05) * 0.2
    assert score == round(expected_score, 2)


def test_compute_score_high_review_count_approaches_average() -> None:
    row = FakeQualityScore(2, review_count=100, average_rating=4.5, on_time_delivery_rate=0.95, defect_rate=0.02)
    global_avg = 3.0
    score = _compute_score(row, global_avg)

    weight = min(1.0, 100 / 30)
    expected_rating = weight * 4.5 + (1 - weight) * 3.0
    expected_score = expected_rating * 0.5 + 0.95 * 0.3 + (1 - 0.02) * 0.2
    assert score == round(expected_score, 2)


@patch("app.services.quality_score_job.update_payloads")
def test_compute_quality_scores_empty(mock_update: MagicMock) -> None:
    mock_session = MagicMock()
    mock_result = MagicMock()
    mock_result.scalars.return_value.all.return_value = []
    mock_session.execute.return_value = mock_result

    result = compute_quality_scores(mock_session)

    assert result == []
