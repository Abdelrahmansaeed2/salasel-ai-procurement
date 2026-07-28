from langgraph.graph import END, StateGraph

from app.agents.checkpointer import get_checkpointer
from app.agents.nodes.ask_missing_spec import ask_missing_spec_node
from app.agents.nodes.conversation import conversation_node
from app.agents.nodes.rag_lookup import rag_lookup_node
from app.agents.nodes.retriever import retriever_node
from app.agents.nodes.router import route_after_conversation
from app.agents.state import InventoryState

_compiled_graph = None


def build_graph() -> StateGraph:
    builder = StateGraph(InventoryState)

    builder.add_node("conversation_agent", conversation_node)
    builder.add_node("ask_missing_spec", ask_missing_spec_node)
    builder.add_node("rag_lookup", rag_lookup_node)
    builder.add_node("retriever", retriever_node)

    builder.set_entry_point("conversation_agent")
    builder.add_conditional_edges("conversation_agent", route_after_conversation, {
        "ask_missing_spec": "ask_missing_spec",
        "rag_lookup": "rag_lookup",
        "retriever": "retriever",
    })
    builder.add_edge("ask_missing_spec", END)
    builder.add_edge("rag_lookup", "conversation_agent")
    builder.add_edge("retriever", END)

    return builder


def get_compiled_graph():
    global _compiled_graph
    if _compiled_graph is None:
        checkpointer = get_checkpointer()
        _compiled_graph = build_graph().compile(checkpointer=checkpointer)
    return _compiled_graph
