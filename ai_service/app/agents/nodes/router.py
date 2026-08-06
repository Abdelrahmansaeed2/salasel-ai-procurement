from typing import Literal

from app.agents.state import InventoryState, ProductSpec, is_spec_complete


def route_after_conversation(state: InventoryState) -> Literal["ask_missing_spec", "resolve_product", "ask_attributes", "retriever"]:
    spec = ProductSpec.model_validate(state["spec"])
    if not is_spec_complete(spec):
        return "ask_missing_spec"
    if spec.needs_attribute_lookup or spec.category is None:
        return "resolve_product"
    if state.get("pending_attributes"):
        return "ask_attributes"
    return "retriever"
