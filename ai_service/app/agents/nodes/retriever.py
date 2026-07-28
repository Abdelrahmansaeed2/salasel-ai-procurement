from langchain_core.messages import AIMessage

from app.agents.state import InventoryState


def retriever_node(state: InventoryState) -> dict:
    return {
        "messages": [AIMessage(content="Retriever agent not yet implemented — this is a placeholder.")],
        "turn_status": "done",
    }
