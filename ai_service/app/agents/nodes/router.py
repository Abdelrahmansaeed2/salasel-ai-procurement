from typing import Literal

from app.agents.state import InventoryState, is_spec_complete


def route_after_conversation(state: InventoryState) -> Literal["rag_lookup", "ask_missing_spec", "retriever"]:
    if state["spec"].needs_attribute_lookup:
        return "rag_lookup"
    if not is_spec_complete(state["spec"]):
        return "ask_missing_spec"
    return "retriever"
