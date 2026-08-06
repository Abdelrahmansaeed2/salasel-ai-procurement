from typing import Literal

from app.agents.state import InventoryState, ProductSpec, is_spec_complete


def route_after_conversation(state: InventoryState) -> Literal["rag_lookup", "ask_missing_spec", "retriever"]:
    spec = ProductSpec.model_validate(state["spec"])
    if spec.needs_attribute_lookup:
        return "rag_lookup"
    if not is_spec_complete(spec):
        return "ask_missing_spec"
    return "retriever"
