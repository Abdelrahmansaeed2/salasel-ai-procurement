from langchain_core.messages import HumanMessage
from langchain_core.runnables import RunnableConfig
from pydantic import BaseModel

from app.agents.checkpointer import get_checkpointer
from app.agents.graph import get_compiled_graph
from app.agents.state import InventoryState, ProductSpec
from fastapi import APIRouter, HTTPException, status

router = APIRouter(tags=["chat"])


class ChatRequest(BaseModel):
    session_id: str
    message: str


class ChatResponse(BaseModel):
    response: str
    spec: ProductSpec
    turn_status: str
    missing_fields: list[str]


@router.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest) -> ChatResponse:
    config: RunnableConfig = {"configurable": {"thread_id": request.session_id}}
    checkpointer = get_checkpointer()
    existing = checkpointer.get_tuple(config)

    if existing is None:
        input_message = InventoryState(
            messages=[HumanMessage(content=request.message)],
            spec=ProductSpec(),
            customer_location=None,
            candidates=[],
            ranked_results=[],
            rejected_ids=[],
            rank_weights={"sim": 1.0, "quality": 0.7, "distance": 0.5},
            missing_fields=[],
            turn_status="ask",
        )
    else:
        input_message = {"messages": [HumanMessage(content=request.message)]}

    try:
        graph = get_compiled_graph()
        result = graph.invoke(input_message, config)
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Error occurred while invoking the graph: {str(e)}")

    last_message = result["messages"][-1] if result["messages"] else None
    return ChatResponse(
        response=last_message.content if last_message else "",
        spec=result["spec"],
        turn_status=result.get("turn_status", "ask"),
        missing_fields=result.get("missing_fields", []),
    )
