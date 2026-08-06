from typing import Literal

from langgraph.graph import END, StateGraph

from app.agents.checkpointer import get_checkpointer
from app.agents.nodes.ask_attributes import ask_attributes_node
from app.agents.nodes.ask_missing_spec import ask_missing_spec_node
from app.agents.nodes.conversation import conversation_node
from app.agents.nodes.format_results import format_results_node
from app.agents.nodes.rerank import rerank_node
from app.agents.nodes.resolve_product import resolve_product_node
from app.agents.nodes.retriever import retriever_node
from app.agents.nodes.review import review_gate_node, route_after_review
from app.agents.nodes.router import route_after_conversation
from app.agents.state import InventoryState, ProductSpec

_compiled_graph = None


def route_after_resolve(state: InventoryState) -> Literal["ask_attributes", "END"]:
    spec = ProductSpec.model_validate(state["spec"])
    return "ask_attributes" if spec.category is not None else END


def route_after_attribute(state: InventoryState) -> Literal["retriever", "END"]:
    return "retriever" if not state.get("attribute_prompt") else END


def route_after_retriever(state: InventoryState) -> Literal["format_results", "END"]:
    return "format_results" if state.get("ranked_results") else END


def build_graph() -> StateGraph:
    builder = StateGraph(InventoryState)

    builder.add_node("conversation_agent", conversation_node)
    builder.add_node("ask_missing_spec", ask_missing_spec_node)
    builder.add_node("resolve_product", resolve_product_node)
    builder.add_node("ask_attributes", ask_attributes_node)
    builder.add_node("retriever", retriever_node)
    builder.add_node("format_results", format_results_node)
    builder.add_node("review_gate", review_gate_node)
    builder.add_node("rerank", rerank_node)

    builder.set_entry_point("conversation_agent")
    builder.add_conditional_edges("conversation_agent", route_after_conversation, {
        "ask_missing_spec": "ask_missing_spec",
        "resolve_product": "resolve_product",
        "ask_attributes": "ask_attributes",
        "retriever": "retriever",
    })
    builder.add_edge("ask_missing_spec", END)
    builder.add_conditional_edges("resolve_product", route_after_resolve, {
        "ask_attributes": "ask_attributes",
        END: END,
    })
    builder.add_conditional_edges("ask_attributes", route_after_attribute, {
        "retriever": "retriever",
        END: END,
    })
    builder.add_conditional_edges("retriever", route_after_retriever, {
        "format_results": "format_results",
        END: END,
    })
    builder.add_edge("format_results", "review_gate")
    builder.add_conditional_edges("review_gate", route_after_review, {
        "rerank": "rerank",
        "done": END,
    })
    builder.add_edge("rerank", "retriever")

    return builder


def get_compiled_graph():
    global _compiled_graph
    if _compiled_graph is None:
        checkpointer = get_checkpointer()
        _compiled_graph = build_graph().compile(checkpointer=checkpointer)
    return _compiled_graph
