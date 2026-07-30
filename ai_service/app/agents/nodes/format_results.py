from langchain_core.messages import AIMessage, SystemMessage, HumanMessage

from app.agents.state import InventoryState
from app.core.llm import get_llm

FORMAT_RESULTS_SYSTEM_PROMPT = (
    "You are given 5 ranked product/supplier matches as structured data. "
    "Write one short line per result explaining why it matches (price, quality, "
    "distance) in plain language. Do not alter, reorder, or invent values "
    "\u2014 use exactly the numbers provided."
)


def format_results_node(state: InventoryState) -> dict:
    ranked = state.get("ranked_results", [])
    if not ranked:
        return {
            "messages": [AIMessage(content="No results to display.")],
            "turn_status": "confirm",
        }

    llm = get_llm(role="formatting")
    text = llm.invoke([
        SystemMessage(content=FORMAT_RESULTS_SYSTEM_PROMPT),
        HumanMessage(content=str([r.model_dump() for r in ranked])),
    ])

    return {
        "messages": [AIMessage(content=text.content)],
        "turn_status": "confirm",
    }
