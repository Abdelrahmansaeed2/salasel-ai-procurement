from langgraph.graph import END, StateGraph

from app.agents.order.nodes import (
    enrich_metadata_node,
    extract_products_node,
    generate_order_node,
    match_best_node,
    resolve_defaults_node,
)
from app.agents.order.state import OrderState

_compiled_graph = None


def build_graph() -> StateGraph:
    builder = StateGraph(OrderState)
    builder.add_node("extract_products", extract_products_node)
    builder.add_node("enrich_metadata", enrich_metadata_node)
    builder.add_node("resolve_defaults", resolve_defaults_node)
    builder.add_node("match_best", match_best_node)
    builder.add_node("generate_order", generate_order_node)

    builder.set_entry_point("extract_products")
    builder.add_edge("extract_products", "enrich_metadata")
    builder.add_edge("enrich_metadata", "resolve_defaults")
    builder.add_edge("resolve_defaults", "match_best")
    builder.add_edge("match_best", "generate_order")
    builder.add_edge("generate_order", END)
    return builder


def get_compiled_graph():
    global _compiled_graph
    if _compiled_graph is None:
        _compiled_graph = build_graph().compile()
    return _compiled_graph