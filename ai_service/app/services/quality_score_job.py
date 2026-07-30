import logging
from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.models import SupplierQualityScore
from app.services.vector_store import update_payloads

logger = logging.getLogger(__name__)

REVIEW_SCALE = 30


def _compute_score(row: SupplierQualityScore, global_avg: float) -> float:
    weight = min(1.0, row.review_count / REVIEW_SCALE)
    adjusted = weight * float(row.average_rating) + (1 - weight) * global_avg
    score = (
        adjusted * 0.5
        + float(row.on_time_delivery_rate) * 0.3
        + (1 - float(row.defect_rate)) * 0.2
    )
    return round(score, 2)


def compute_quality_scores(session: Session) -> list[tuple[int, float]]:
    rows = session.execute(
        select(SupplierQualityScore)
    ).scalars().all()

    if not rows:
        logger.info("No SupplierQualityScore rows found — nothing to compute")
        return []

    total = sum(float(r.average_rating) for r in rows)
    global_avg = total / len(rows)

    results: list[tuple[int, float]] = []
    for row in rows:
        score = _compute_score(row, global_avg)
        results.append((row.supplier_id, score))

    return results


def run_quality_score_update(session: Session) -> None:
    scores = compute_quality_scores(session)

    if not scores:
        return

    for supplier_id, score in scores:
        session.execute(
            select(SupplierQualityScore).where(
                SupplierQualityScore.supplier_id == supplier_id
            )
        )
        existing = session.get(SupplierQualityScore, supplier_id)
        if existing:
            existing.quality_score = Decimal(str(score))

    session.commit()

    from app.db.models import SupplierCatalog

    catalog_rows = session.execute(
        select(SupplierCatalog.catalog_id, SupplierCatalog.supplier_id).where(
            SupplierCatalog.supplier_id.in_([s[0] for s in scores])
        )
    ).all()

    qdrant_updates: list[tuple[str, dict]] = []
    score_map = dict(scores)
    for catalog_id, supplier_id in catalog_rows:
        quality = score_map.get(supplier_id)
        if quality is not None:
            qdrant_updates.append((str(catalog_id), {"quality_score": quality}))

    if qdrant_updates:
        update_payloads(qdrant_updates)
        logger.info("Updated quality_score payload for %d products in Qdrant", len(qdrant_updates))

    logger.info("Quality score update complete — %d suppliers processed", len(scores))
