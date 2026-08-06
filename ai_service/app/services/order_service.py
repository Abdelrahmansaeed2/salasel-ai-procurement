import logging

from app.agents.order.graph import get_compiled_graph
from app.agents.order.state import OrderState
from app.schemas.order import OrderPipelineSchema, OrderResponse

logger = logging.getLogger(__name__)


class OrderGraphError(Exception):
    """Raised when the order pipeline fails to produce a schema."""


def run_order_pipeline(request: OrderPipelineSchema) -> OrderResponse:
    logger.info(
        "order pipeline merchant=%s transcript=%r",
        request.merchant_id,
        request.transcript[:80],
    )
    initial: OrderState = {
        "transcript": request.transcript,
        "merchant_id": request.merchant_id,
        "customer_location": request.customer_location,
        "lines": [],
        "order": None,
        "errors": [],
    }
    try:
        result = get_compiled_graph().invoke(initial)
    except Exception as exc:
        logger.exception("order pipeline failed for merchant=%s", request.merchant_id)
        raise OrderGraphError(str(exc)) from exc

    order: OrderResponse = result.get("order")
    if order is None:
        logger.warning("order pipeline produced no schema for merchant=%s", request.merchant_id)
        raise OrderGraphError("No order schema was produced")
    logger.info(
        "order pipeline complete merchant=%s splits=%d total=%.2f",
        request.merchant_id,
        len(order.splits),
        order.total_order_cost,
    )
    return order