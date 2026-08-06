from langchain_core.messages import AIMessage

from app.agents.nodes.ask_attributes import (
    ask_attributes_node,
    attribute_values,
    plan_attributes,
)
from app.agents.state import InventoryState, ProductSpec


def make_state(resolved: list[dict] | None = None, **extra) -> InventoryState:
    state: InventoryState = InventoryState(
        messages=[],
        spec=ProductSpec(product_name="VARIED", category="PPE"),
        customer_location=(40.0, -74.0),
        candidates=[],
        ranked_results=[],
        rejected_ids=[],
        rank_weights={"sim": 1.0, "quality": 0.7, "distance": 0.5},
        missing_fields=[],
        turn_status="ask",
        interrupt_action="",
        resolved_candidates=resolved or [],
        key_attribute=None,
        attribute_options=[],
        attribute_prompt=None,
        key_attribute_asked=False,
        pending_attributes=[],
    )
    state.update(extra)
    return state


def _candidate(pid: str, name: str, attrs: dict) -> dict:
    return {
        "product_id": pid,
        "similarity_score": 0.9,
        "payload": {"product_name": name, "attributes": attrs},
    }


VARIED = [
    _candidate("1", "VARIED", {"size": "S", "material": "nitrile"}),
    _candidate("2", "VARIED", {"size": "M", "material": "latex"}),
    _candidate("3", "VARIED", {"size": "L", "material": "nitrile"}),
]


def test_plan_attributes_most_varied_first() -> None:
    assert plan_attributes(VARIED) == ["size", "material"]


def test_plan_attributes_skips_constant_values() -> None:
    candidates = [
        _candidate("1", "A", {"size": "S", "material": "nitrile"}),
        _candidate("2", "B", {"size": "M", "material": "nitrile"}),
    ]
    assert plan_attributes(candidates) == ["size"]


def test_attribute_values() -> None:
    assert attribute_values(VARIED, "size") == ["L", "M", "S"]


def test_asks_first_attribute_in_sequence() -> None:
    result = ask_attributes_node(make_state(VARIED))

    assert result["key_attribute"] == "size"
    assert result["attribute_prompt"] == "What size would you like? Options: L, M, S"
    assert result["attribute_options"] == ["L", "M", "S"]
    assert result["key_attribute_asked"] is True
    assert result["pending_attributes"] == ["material"]
    assert result["turn_status"] == "ask"
    assert isinstance(result["messages"][0], AIMessage)


def test_asks_next_attribute_after_previous_answer() -> None:
    state = make_state(VARIED)
    state["key_attribute_asked"] = True
    state["pending_attributes"] = ["material"]
    state["spec"].required_attributes = {"size": "M"}

    result = ask_attributes_node(state)

    assert result["key_attribute"] == "material"
    assert "material" in result["attribute_prompt"]
    assert result["pending_attributes"] == []


def test_ends_sequence_when_all_answered() -> None:
    state = make_state(VARIED)
    state["key_attribute_asked"] = True
    state["pending_attributes"] = []
    state["spec"].required_attributes = {"size": "M", "material": "nitrile"}

    result = ask_attributes_node(state)

    assert result["attribute_prompt"] is None
    assert result["pending_attributes"] == []


def test_skips_attributes_already_answered() -> None:
    state = make_state(VARIED)
    state["spec"].required_attributes = {"size": "M"}

    result = ask_attributes_node(state)

    assert result["key_attribute"] == "material"
    assert result["pending_attributes"] == []


def test_nothing_to_ask_when_no_varying_attribute() -> None:
    identical = [
        _candidate("1", "VARIED", {"size": "One Size", "material": "nitrile"}),
        _candidate("2", "VARIED", {"size": "One Size", "material": "nitrile"}),
    ]
    result = ask_attributes_node(make_state(identical))
    assert result["attribute_prompt"] is None


def test_no_candidates_skips_question() -> None:
    result = ask_attributes_node(make_state([]))
    assert result["attribute_prompt"] is None
