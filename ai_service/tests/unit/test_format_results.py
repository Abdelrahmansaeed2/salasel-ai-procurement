from unittest.mock import MagicMock, patch

from langchain_core.messages import AIMessage

from app.agents.state import Candidate, InventoryState, ProductSpec


def make_state(ranked: list[Candidate] | None = None) -> InventoryState:
    return InventoryState(
        messages=[],
        spec=ProductSpec(category="PPE", price_min=50.0, price_max=200.0),
        customer_location=(40.0, -74.0),
        candidates=[],
        ranked_results=ranked or [],
        rejected_ids=[],
        rank_weights={"sim": 1.0, "quality": 0.7, "distance": 0.5},
        missing_fields=[],
        turn_status="ask",
        interrupt_action="",
    )


@patch("app.agents.nodes.format_results.get_llm")
def test_format_results_returns_formatted_message(mock_get_llm: MagicMock) -> None:
    mock_llm = MagicMock()
    mock_llm.invoke.return_value = AIMessage(content="1. Product P1 - $100, good quality")
    mock_get_llm.return_value = mock_llm

    ranked = [
        Candidate(product_id="P1", supplier_id="S1", similarity_score=0.95, quality_score=0.9, distance_km=5.0, price=100.0),
    ]
    state = make_state(ranked)
    from app.agents.nodes.format_results import format_results_node
    result = format_results_node(state)

    assert result["turn_status"] == "confirm"
    assert len(result["messages"]) == 1
    assert "Product P1" in result["messages"][0].content
    mock_get_llm.assert_called_once_with(role="formatting")


@patch("app.agents.nodes.format_results.get_llm")
def test_format_results_does_not_alter_scores(mock_get_llm: MagicMock) -> None:
    mock_llm = MagicMock()
    mock_llm.invoke.return_value = AIMessage(content="some description")
    mock_get_llm.return_value = mock_llm

    ranked = [
        Candidate(product_id="P1", supplier_id="S1", similarity_score=0.95, quality_score=0.9, distance_km=5.0, price=100.0),
        Candidate(product_id="P2", supplier_id="S2", similarity_score=0.80, quality_score=0.7, distance_km=15.0, price=50.0),
    ]
    state = make_state(ranked)
    input_scores = [(r.similarity_score, r.quality_score, r.distance_km) for r in ranked]

    from app.agents.nodes.format_results import format_results_node
    result = format_results_node(state)

    assert "ranked_results" not in result
    assert input_scores == [(r.similarity_score, r.quality_score, r.distance_km) for r in ranked]


def test_format_results_handles_empty_ranked() -> None:
    state = make_state([])
    from app.agents.nodes.format_results import format_results_node
    result = format_results_node(state)

    assert result["turn_status"] == "confirm"
    assert "No results" in result["messages"][0].content
