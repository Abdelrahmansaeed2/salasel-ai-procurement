from app.agents.state import Candidate, InventoryState

ADJUSTMENT_MAP: dict[str, dict[str, float]] = {
    "expensive": {"price": 0.3, "quality": 0.2},
    "too far": {"distance": 0.3, "quality": 0.1},
    "low quality": {"quality": 0.3, "sim": 0.1},
    "cheap": {"price": -0.2},
    "close": {"distance": -0.2},
}


def adjust_weights(current: dict[str, float], reason: str) -> dict[str, float]:
    updated = dict(current)
    reason_lower = reason.lower()

    matched = False
    for keyword, deltas in ADJUSTMENT_MAP.items():
        if keyword in reason_lower:
            matched = True
            for key, delta in deltas.items():
                if key not in updated:
                    updated[key] = 0.0
                updated[key] = max(0.0, updated[key] + delta)
            break

    if not matched:
        updated["distance"] = updated.get("distance", 0.5) + 0.1

    return updated


def rerank_node(state: InventoryState) -> dict:
    ranked = state.get("ranked_results", [])
    rejected = list(state.get("rejected_ids", []))
    for c in ranked:
        pid = c.product_id if isinstance(c, Candidate) else str(c.get("product_id", ""))
        if pid and pid not in rejected:
            rejected.append(pid)

    last_msg = state.get("messages", [])
    reason = last_msg[-1].content if last_msg else ""

    weights = adjust_weights(state.get("rank_weights", {"sim": 1.0, "quality": 0.7, "distance": 0.5}), reason)

    return {
        "rejected_ids": rejected,
        "rank_weights": weights,
        "turn_status": "rerank",
    }
