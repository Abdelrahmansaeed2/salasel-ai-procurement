from langchain_core.messages import AIMessage

from app.agents.nodes.rerank import adjust_weights, rerank_node
from app.agents.state import Candidate, InventoryState, ProductSpec


def make_state(ranked: list[Candidate] | None = None, rejected: list[str] | None = None, message: str = "") -> InventoryState:
    return InventoryState(
        messages=[AIMessage(content=message)] if message else [],
        spec=ProductSpec(category="PPE", price_min=50.0, price_max=200.0),
        customer_location=(40.0, -74.0),
        candidates=[],
        ranked_results=ranked or [],
        rejected_ids=rejected or [],
        rank_weights={"sim": 1.0, "quality": 0.7, "distance": 0.5},
        missing_fields=[],
        turn_status="confirm",
        interrupt_action="",
    )


def test_adjust_weights_too_expensive() -> None:
    updated = adjust_weights({"sim": 1.0, "quality": 0.7, "distance": 0.5}, "too expensive")
    assert updated["price"] == 0.3
    assert round(updated["quality"], 6) == 0.9


def test_adjust_weights_too_far() -> None:
    updated = adjust_weights({"sim": 1.0, "quality": 0.7, "distance": 0.5}, "too far")
    assert updated["distance"] == 0.8
    assert round(updated["quality"], 6) == 0.8


def test_adjust_weights_low_quality() -> None:
    updated = adjust_weights({"sim": 1.0, "quality": 0.7, "distance": 0.5}, "low quality")
    assert updated["quality"] == 1.0
    assert updated["sim"] == 1.1


def test_adjust_weights_no_match_increases_distance() -> None:
    updated = adjust_weights({"sim": 1.0, "quality": 0.7, "distance": 0.5}, "i want a different color")
    assert updated["distance"] == 0.6


def test_rerank_node_appends_rejected_ids() -> None:
    ranked = [
        Candidate(product_id="P1", supplier_id="S1", similarity_score=0.95, quality_score=0.9, distance_km=5.0, price=100.0),
        Candidate(product_id="P2", supplier_id="S2", similarity_score=0.80, quality_score=0.7, distance_km=10.0, price=50.0),
    ]
    state = make_state(ranked=ranked, rejected=["P0"], message="too expensive")
    result = rerank_node(state)

    assert "P1" in result["rejected_ids"]
    assert "P2" in result["rejected_ids"]
    assert "P0" in result["rejected_ids"]
    assert result["turn_status"] == "rerank"


def test_rerank_node_no_duplicates() -> None:
    ranked = [
        Candidate(product_id="P1", supplier_id="S1", similarity_score=0.95, quality_score=0.9, distance_km=5.0, price=100.0),
    ]
    state = make_state(ranked=ranked, rejected=["P1"], message="too expensive")
    result = rerank_node(state)

    assert result["rejected_ids"].count("P1") == 1
