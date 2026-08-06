from typing import Literal

from langgraph.types import interrupt

from app.agents.state import InventoryState


def review_gate_node(state: InventoryState) -> dict:
    response = interrupt({"results": state.get("ranked_results", [])})
    action = response.get("action", "confirm") if isinstance(response, dict) else "confirm"
    return {"interrupt_action": action}


def route_after_review(state: InventoryState) -> Literal["rerank", "done"]:
    action = state.get("interrupt_action", "confirm")
    return "rerank" if action == "reject" else "done"
