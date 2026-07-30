from langchain_core.messages import HumanMessage
from langchain_core.runnables import RunnableConfig
from langgraph.types import Command
from pydantic import BaseModel

from app.agents.checkpointer import get_checkpointer
from app.agents.graph import get_compiled_graph
from app.agents.state import Candidate, InventoryState, ProductSpec
from fastapi import APIRouter, HTTPException, status

router = APIRouter(tags=["chat"])

_CONFIRM_KEYWORDS = {"yes", "confirm", "accept", "approve", "looks good"}


class ChatRequest(BaseModel):
    session_id: str
    message: str


class ChatResponse(BaseModel):
    response: str
    spec: ProductSpec
    turn_status: str
    missing_fields: list[str]
    ranked_results: list[Candidate]


def _parse_review_decision(message: str) -> dict:
    msg_lower = message.strip().lower()
    if any(kw in msg_lower for kw in _CONFIRM_KEYWORDS):
        return {"action": "confirm"}
    return {"action": "reject", "reason": message}


def _fresh_state(message: str) -> InventoryState:
    return InventoryState(
        messages=[HumanMessage(content=message)],
        spec=ProductSpec(),
        customer_location=None,
        candidates=[],
        ranked_results=[],
        rejected_ids=[],
        rank_weights={"sim": 1.0, "quality": 0.7, "distance": 0.5},
        missing_fields=[],
        turn_status="ask",
        interrupt_action="",
    )


@router.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest) -> ChatResponse:
    config: RunnableConfig = {"configurable": {"thread_id": request.session_id}}
    checkpointer = get_checkpointer()
    graph = get_compiled_graph()
    existing = checkpointer.get_tuple(config)

    try:
        if existing is None:
            result = graph.invoke(_fresh_state(request.message), config)
        else:
            state_snapshot = graph.get_state(config)
            pending_interrupt = any(
                t.interrupts for t in (state_snapshot.tasks or [])
            )
            if pending_interrupt:
                decision = _parse_review_decision(request.message)
                result = graph.invoke(Command(resume=decision), config)
            else:
                result = graph.invoke(
                    {"messages": [HumanMessage(content=request.message)]},
                    config,
                )
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Error occurred while invoking the graph: {str(e)}")

    last_message = result["messages"][-1] if result["messages"] else None
    return ChatResponse(
        response=last_message.content if last_message else "",
        spec=result["spec"],
        turn_status=result.get("turn_status", "ask"),
        missing_fields=result.get("missing_fields", []),
        ranked_results=result.get("ranked_results", []),
    )
