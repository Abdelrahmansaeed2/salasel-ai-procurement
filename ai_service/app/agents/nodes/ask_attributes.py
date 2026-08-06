from langchain_core.messages import AIMessage

from app.agents.state import InventoryState


def plan_attributes(candidates: list[dict]) -> list[str]:
    """Attributes to ask about, most-varied first.

    Only attributes with more than one distinct value across candidates are
    asked (things all candidates share are noise). Attributes the customer has
    already specified are filtered out by the caller.
    """
    by_key: dict[str, set[str]] = {}
    for c in candidates:
        attrs = (c.get("payload") or {}).get("attributes") or {}
        for key, value in attrs.items():
            by_key.setdefault(str(key), set()).add(str(value))

    varying = {k: values for k, values in by_key.items() if len(values) > 1}
    return sorted(varying, key=lambda k: -len(varying[k]))


def attribute_values(candidates: list[dict], attribute: str) -> list[str]:
    distinct: set[str] = set()
    for c in candidates:
        attrs = (c.get("payload") or {}).get("attributes") or {}
        value = attrs.get(attribute)
        if value is not None:
            distinct.add(str(value))
    return sorted(distinct)


def ask_attributes_node(state: InventoryState) -> dict:
    spec = state["spec"]
    candidates = state.get("resolved_candidates", [])
    if not candidates:
        return {"attribute_prompt": None}

    answered = set((spec.required_attributes or {}).keys())
    sequence_started = bool(state.get("key_attribute_asked"))

    if not sequence_started:
        pending = [a for a in plan_attributes(candidates) if a not in answered]
        if not pending:
            return {"attribute_prompt": None}
        key_attribute_asked = True
    else:
        pending = [a for a in state.get("pending_attributes", []) if a not in answered]
        key_attribute_asked = True

    if not pending:
        return {
            "attribute_prompt": None,
            "key_attribute_asked": True,
            "pending_attributes": [],
        }

    current = pending[0]
    remaining = pending[1:]
    options = attribute_values(candidates, current)
    question = f"What {current} would you like? Options: {', '.join(options)}"

    return {
        "messages": [AIMessage(content=question)],
        "key_attribute": current,
        "attribute_options": options,
        "attribute_prompt": question,
        "key_attribute_asked": key_attribute_asked,
        "pending_attributes": remaining,
        "turn_status": "ask",
    }