import logging

from apscheduler.schedulers.background import BackgroundScheduler

from app.db.session import get_sync_sessionmaker
from app.services.quality_score_job import run_quality_score_update

logger = logging.getLogger(__name__)

_scheduler: BackgroundScheduler | None = None


def start_scheduler() -> None:
    global _scheduler
    if _scheduler is not None:
        return

    _scheduler = BackgroundScheduler()
    _scheduler.add_job(
        _run_job,
        "cron",
        hour=2,
        minute=0,
        id="quality_score_nightly",
        replace_existing=True,
    )
    _scheduler.start()
    logger.info("Quality score scheduler started (nightly at 02:00)")


def stop_scheduler() -> None:
    global _scheduler
    if _scheduler is not None:
        _scheduler.shutdown(wait=False)
        _scheduler = None
        logger.info("Quality score scheduler stopped")


def _run_job() -> None:
    logger.info("Starting quality score batch job")
    try:
        session_factory = get_sync_sessionmaker()
        with session_factory() as session:
            run_quality_score_update(session)
    except Exception:
        logger.exception("Quality score batch job failed")
