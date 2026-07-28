from langchain_core.messages import AIMessage

from app.agents.state import REQUIRED_FIELDS, InventoryState

FOLLOWUP_TEMPLATES: dict[str, str] = {
    "category": "What category of product are you looking for?",
    "price_min": "What is your minimum budget for this product?",
    "price_max": "What is the maximum price you are willing to pay?",
}


def ask_missing_spec_node(state: InventoryState) -> dict:
    missing = [f for f in REQUIRED_FIELDS if getattr(state["spec"], f) is None]
    if not missing:
        return {"missing_fields": []}
    question = FOLLOWUP_TEMPLATES.get(missing[0], "Could you provide more details about what you need?")
    return {"messages": [AIMessage(content=question)], "missing_fields": missing}
