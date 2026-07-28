from langchain_core.messages import SystemMessage

from app.agents.state import InventoryState


def rag_lookup_node(state: InventoryState) -> dict:
    return {
        "messages": [SystemMessage(content="RAG lookup not yet implemented — returning to conversation.")],
    }
