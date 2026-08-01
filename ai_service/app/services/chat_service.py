import logging

from langchain_core.messages import HumanMessage
from langchain_core.runnables import RunnableConfig
from langgraph.types import Command

from app.agents.checkpointer import get_checkpointer
from app.agents.graph import get_compiled_graph
from app.agents.state import InventoryState, ProductSpec
from app.schemas.chat import ChatResponse

logger = logging.getLogger(__name__)

_CONFIRM_KEYWORDS = {"yes", "confirm", "accept", "approve", "looks good"}


class ChatGraphError(Exception):
    """Raised when the LangGraph pipeline fails to produce a turn."""


def _parse_review_decision(message: str) -> dict:
    msg_lower = message.strip().lower()
    if any(kw in msg_lower for kw in _CONFIRM_KEYWORDS):
        return {"action": "confirm"}
    return {"action": "reject", "reason": message}


def _fresh_state(message: str, customer_location: tuple[float, float] | None = None) -> InventoryState:
    return InventoryState(
        messages=[HumanMessage(content=message)],
        spec=ProductSpec(),
        customer_location=customer_location,
        candidates=[],
        ranked_results=[],
        rejected_ids=[],
        rank_weights={"sim": 1.0, "quality": 0.7, "distance": 0.5},
        missing_fields=[],
        turn_status="ask",
        interrupt_action="",
    )


async def run_chat(
    session_id: str,
    message: str,
    customer_location: tuple[float, float] | None = None,
) -> ChatResponse:
    config: RunnableConfig = {"configurable": {"thread_id": session_id}}
    logger.info("chat run session=%s message=%r", session_id, message)
    try:
        checkpointer = get_checkpointer()
        graph = get_compiled_graph()
        existing = checkpointer.get_tuple(config)
        logger.info("chat session=%s existing=%s", session_id, existing is not None)

        if existing is None:
            result = graph.invoke(_fresh_state(message, customer_location), config)
        else:
            state_snapshot = graph.get_state(config)
            pending_interrupt = any(
                t.interrupts for t in (state_snapshot.tasks or [])
            )
            if pending_interrupt:
                decision = _parse_review_decision(message)
                result = graph.invoke(Command(resume=decision), config)
            else:
                state_update: dict = {
                    "messages": [HumanMessage(content=message)],
                }
                if customer_location is not None:
                    state_update["customer_location"] = customer_location
                result = graph.invoke(state_update, config)
    except Exception as exc:
        logger.exception("graph invocation failed for session %s", session_id)
        raise ChatGraphError(str(exc)) from exc

    last_message = result["messages"][-1] if result["messages"] else None
    response = ChatResponse(
        response=last_message.content if last_message else "",
        spec=result["spec"],
        turn_status=result.get("turn_status", "ask"),
        missing_fields=result.get("missing_fields", []),
        ranked_results=result.get("ranked_results", []),
    )
    logger.info("chat run complete session=%s turn_status=%s", session_id, response.turn_status)
    return response
