from app.schemas.product import SupplierQualityMetrics

REVIEW_SCALE = 30


def compute_supplier_score(
    *,
    review_count: int,
    average_rating: float,
    on_time_delivery_rate: float,
    defect_rate: float,
    global_avg: float,
) -> float:
    """Blend a supplier's review metrics toward the global average, then combine
    rating / delivery / defect signals into a 0-100-style quality score."""
    weight = min(1.0, review_count / REVIEW_SCALE)
    adjusted = weight * average_rating + (1 - weight) * global_avg
    score = (
        adjusted * 0.5
        + on_time_delivery_rate * 0.3
        + (1 - defect_rate) * 0.2
    )
    return round(score, 2)


def compute_scores(metrics: list[SupplierQualityMetrics]) -> list[tuple[int, float]]:
    """Compute quality scores for a batch of supplier metrics.

    The global average rating is derived from the batch itself, matching the
    behavior of the nightly SQL job.
    """
    if not metrics:
        return []
    global_avg = sum(m.average_rating for m in metrics) / len(metrics)
    return [
        (
            m.supplier_id,
            compute_supplier_score(
                review_count=m.review_count,
                average_rating=m.average_rating,
                on_time_delivery_rate=m.on_time_delivery_rate,
                defect_rate=m.defect_rate,
                global_avg=global_avg,
            ),
        )
        for m in metrics
    ]
