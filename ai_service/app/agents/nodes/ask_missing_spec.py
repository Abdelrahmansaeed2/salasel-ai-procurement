from langchain_core.messages import AIMessage

from app.agents.state import InventoryState, ProductSpec, missing_fields

FOLLOWUP_TEMPLATES: dict[str, str] = {
    "product_name": "What product are you looking for? For example: nitrile gloves, KN95 masks, or safety goggles.",
    "price": "What is your budget? For example: up to $50, or between $20 and $100.",
}


def ask_missing_spec_node(state: InventoryState) -> dict:
    spec = ProductSpec.model_validate(state["spec"])
    missing = missing_fields(spec)
    if not missing:
        return {"missing_fields": []}
    question = FOLLOWUP_TEMPLATES.get(missing[0], "Could you provide more details about what you need?")
    return {"messages": [AIMessage(content=question)], "missing_fields": missing}
