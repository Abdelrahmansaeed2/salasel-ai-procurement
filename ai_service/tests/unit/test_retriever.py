from unittest.mock import MagicMock, patch

from langchain_core.messages import AIMessage

from app.agents.nodes.retriever import _canonical_attribute_value
from app.agents.state import Candidate, InventoryState, ProductSpec


def make_state(spec: ProductSpec | None = None, location: tuple[float, float] | None = None) -> InventoryState:
    return InventoryState(
        messages=[],
        spec=spec or ProductSpec(category="PPE", price_min=50.0, price_max=200.0),
        customer_location=location,
        candidates=[],
        ranked_results=[],
        rejected_ids=[],
        rank_weights={"sim": 1.0, "quality": 0.7, "distance": 0.5},
        missing_fields=[],
        turn_status="ask",
    )


def test_retriever_asks_for_location_when_missing() -> None:
    spec = ProductSpec(category="PPE", price_min=50.0, price_max=200.0)
    state = make_state(spec, location=None)
    from app.agents.nodes.retriever import retriever_node
    result = retriever_node(state)

    assert result["turn_status"] == "ask"
    assert len(result["messages"]) == 1
    assert "location" in result["messages"][0].content.lower()


def test_canonical_attribute_value_maps_size_words() -> None:
    assert _canonical_attribute_value("small", ["S", "M", "L"]) == "S"
    assert _canonical_attribute_value("MEDIUM", ["S", "M", "L"]) == "M"
    assert _canonical_attribute_value("Large", ["S", "M", "L"]) == "L"
    assert _canonical_attribute_value("S", ["S", "M", "L"]) == "S"
    assert _canonical_attribute_value("one size", ["One Size"]) == "One Size"


def test_canonical_attribute_value_falls_back_to_raw() -> None:
    assert _canonical_attribute_value("blue", ["S", "M", "L"]) == "blue"

@patch("app.agents.nodes.retriever.embed_sync")
@patch("app.agents.nodes.retriever.vector_search")
def test_retriever_rejects_out_of_range_location(
    mock_search: MagicMock, mock_embed: MagicMock
) -> None:
    spec = ProductSpec(category="PPE", price_min=50.0, price_max=200.0)
    state = make_state(spec, location=(120.0, 230.0))
    from app.agents.nodes.retriever import retriever_node
    result = retriever_node(state)

    assert result["turn_status"] == "ask"
    assert any("invalid" in m.content.lower() if isinstance(m, AIMessage) else False for m in result["messages"])
    mock_embed.assert_not_called()
    mock_search.assert_not_called()


@patch("app.agents.nodes.retriever.embed_sync", return_value=[0.1, 0.2, 0.3])
@patch("app.agents.nodes.retriever.vector_search")
@patch("app.agents.nodes.retriever.blend_and_rank")
def test_retriever_returns_ranked_results(
    mock_blend: MagicMock, mock_search: MagicMock, mock_embed: MagicMock
) -> None:
    mock_search.return_value = [
        {"product_id": "P1", "similarity_score": 0.95, "payload": {"supplier_id": "S1", "quality_score": 0.9, "geo": {"lat": 40.0, "lon": -74.0}, "price": 100.0}},
        {"product_id": "P2", "similarity_score": 0.90, "payload": {"supplier_id": "S1", "quality_score": 0.8, "geo": {"lat": 40.0, "lon": -74.0}, "price": 150.0}},
    ]

    mock_blend.return_value = [
        Candidate(product_id="P1", supplier_id="S1", similarity_score=0.95, quality_score=0.9, distance_km=5.0, price=100.0),
        Candidate(product_id="P2", supplier_id="S1", similarity_score=0.90, quality_score=0.8, distance_km=5.0, price=150.0),
    ]

    spec = ProductSpec(category="PPE", price_min=50.0, price_max=200.0)
    state = make_state(spec, location=(40.0, -74.0))
    from app.agents.nodes.retriever import retriever_node
    result = retriever_node(state)

    assert result["turn_status"] == "done"
    assert len(result["ranked_results"]) == 2
    assert result["ranked_results"][0].product_id == "P1"
    assert result["ranked_results"][1].product_id == "P2"
    mock_embed.assert_called_once()
    mock_search.assert_called_once()
    mock_blend.assert_called_once()


@patch("app.agents.nodes.retriever.embed_sync", return_value=[0.1, 0.2, 0.3])
@patch("app.agents.nodes.retriever.vector_search")
def test_retriever_reports_no_results_after_relaxation(
    mock_search: MagicMock, mock_embed: MagicMock
) -> None:
    mock_search.return_value = []

    spec = ProductSpec(category="PPE", price_min=50.0, price_max=200.0)
    state = make_state(spec, location=(40.0, -74.0))
    from app.agents.nodes.retriever import retriever_node
    result = retriever_node(state)

    assert result["turn_status"] == "done"
    assert len(result["ranked_results"]) == 0
    assert any("couldn't find" in m.content.lower() if isinstance(m, AIMessage) else False for m in result["messages"])
    # Should have called search multiple times (initial + relaxations)
    assert mock_search.call_count >= 2


@patch("app.agents.nodes.retriever.embed_sync", return_value=[0.1, 0.2, 0.3])
@patch("app.agents.nodes.retriever.vector_search")
def test_retriever_mentions_relaxed_constraints(
    mock_search: MagicMock, mock_embed: MagicMock
) -> None:
    mock_search.side_effect = [[], [], [{"product_id": "P1", "similarity_score": 0.8, "payload": {"supplier_id": "S1", "quality_score": 0.7, "geo": {"lat": 40.0, "lon": -74.0}, "price": 100.0}}]]

    spec = ProductSpec(category="PPE", price_min=50.0, price_max=200.0)
    state = make_state(spec, location=(40.0, -74.0))
    from app.agents.nodes.retriever import retriever_node
    result = retriever_node(state)

    assert result["turn_status"] == "done"
    assert len(result["ranked_results"]) > 0
    msg_text = " ".join(m.content for m in result["messages"] if isinstance(m, AIMessage))
    assert "radius" in msg_text.lower() or "budget" in msg_text.lower()


@patch("app.agents.nodes.retriever.embed_sync", return_value=[0.1, 0.2, 0.3])
@patch("app.agents.nodes.retriever.vector_search")
@patch("app.agents.nodes.retriever.blend_and_rank")
def test_retriever_passes_attribute_filters(
    mock_blend: MagicMock, mock_search: MagicMock, mock_embed: MagicMock
) -> None:
    mock_search.return_value = [
        {"product_id": "P1", "similarity_score": 0.90, "payload": {"supplier_id": "S1", "quality_score": 0.8, "geo": {"lat": 40.0, "lon": -74.0}, "price": 100.0}},
    ]
    mock_blend.return_value = [
        Candidate(product_id="P1", supplier_id="S1", similarity_score=0.90, quality_score=0.8, distance_km=5.0, price=100.0),
    ]

    spec = ProductSpec(category="PPE", price_min=None, price_max=None)
    spec.required_attributes = {"size": "small", "material": "nitrile"}
    state = make_state(spec, location=(40.0, -74.0))
    state["resolved_candidates"] = [
        {"payload": {"attributes": {"size": "S", "material": "nitrile"}}},
        {"payload": {"attributes": {"size": "M", "material": "nitrile"}}},
    ]
    from app.agents.nodes.retriever import retriever_node
    result = retriever_node(state)

    assert result["turn_status"] == "done"
    _, kwargs = mock_search.call_args
    assert kwargs["attributes"] == [("size", "S"), ("material", "nitrile")]


@patch("app.agents.nodes.retriever.embed_sync", return_value=[0.1, 0.2, 0.3])
@patch("app.agents.nodes.retriever.vector_search")
@patch("app.agents.nodes.retriever.blend_and_rank")
def test_retriever_omits_vague_and_invalid_answers(
    mock_blend: MagicMock, mock_search: MagicMock, mock_embed: MagicMock
) -> None:
    mock_search.return_value = [
        {"product_id": "P1", "similarity_score": 0.90, "payload": {"supplier_id": "S1", "quality_score": 0.8, "geo": {"lat": 40.0, "lon": -74.0}, "price": 100.0}},
    ]
    mock_blend.return_value = [
        Candidate(product_id="P1", supplier_id="S1", similarity_score=0.90, quality_score=0.8, distance_km=5.0, price=100.0),
    ]

    spec = ProductSpec(category="PPE", price_min=50.0, price_max=200.0)
    spec.required_attributes = {"size": "any", "material": "blue"}
    state = make_state(spec, location=(40.0, -74.0))
    state["resolved_candidates"] = [
        {"payload": {"attributes": {"size": "S", "material": "nitrile"}}},
        {"payload": {"attributes": {"size": "M", "material": "nitrile"}}},
    ]
    from app.agents.nodes.retriever import retriever_node
    result = retriever_node(state)

    assert result["turn_status"] == "done"
    _, kwargs = mock_search.call_args
    assert kwargs.get("attributes") is None


@patch("app.agents.nodes.retriever.embed_sync", return_value=[0.1, 0.2, 0.3])
@patch("app.agents.nodes.retriever.vector_search")
@patch("app.agents.nodes.retriever.blend_and_rank")
def test_retriever_excludes_rejected_ids(
    mock_blend: MagicMock, mock_search: MagicMock, mock_embed: MagicMock
) -> None:
    mock_search.return_value = [
        {"product_id": "P2", "similarity_score": 0.90, "payload": {"supplier_id": "S1", "quality_score": 0.8, "geo": {"lat": 40.0, "lon": -74.0}, "price": 150.0}},
    ]
    mock_blend.return_value = [
        Candidate(product_id="P2", supplier_id="S1", similarity_score=0.90, quality_score=0.8, distance_km=5.0, price=150.0),
    ]

    spec = ProductSpec(category="PPE", price_min=50.0, price_max=200.0)
    state = make_state(spec, location=(40.0, -74.0))
    state["rejected_ids"] = ["P1", "P3"]
    from app.agents.nodes.retriever import retriever_node
    result = retriever_node(state)

    assert result["turn_status"] == "done"
    _, kwargs = mock_search.call_args
    assert "excluded_ids" in kwargs
    assert kwargs["excluded_ids"] == ["P1", "P3"]


@patch("app.agents.nodes.retriever.embed_sync", return_value=[0.1, 0.2, 0.3])
@patch("app.agents.nodes.retriever.vector_search")
def test_retriever_falls_back_to_closest_match_without_geo(
    mock_search: MagicMock, mock_embed: MagicMock
) -> None:
    hit = {"product_id": "P1", "similarity_score": 0.80, "payload": {"supplier_id": "S1", "quality_score": 0.7, "geo": {"lat": 40.0, "lon": -74.0}, "price": 100.0}}
    mock_search.side_effect = [[], [], [], [], [hit]]

    spec = ProductSpec(category="PPE", price_min=50.0, price_max=200.0)
    state = make_state(spec, location=(40.0, -74.0))
    from app.agents.nodes.retriever import retriever_node
    result = retriever_node(state)

    assert result["turn_status"] == "done"
    assert len(result["ranked_results"]) > 0
    assert mock_search.call_count == 5
    _, kwargs = mock_search.call_args
    assert kwargs.get("geo_center") is None
    assert kwargs.get("geo_radius_km") is None
    msg_text = " ".join(m.content for m in result["messages"] if isinstance(m, AIMessage))
    assert "closest" in msg_text.lower()


@patch("app.agents.nodes.retriever.embed_sync", return_value=[0.1, 0.2, 0.3])
@patch("app.agents.nodes.retriever.vector_search")
def test_retriever_reports_no_results_when_geo_agnostic_also_empty(
    mock_search: MagicMock, mock_embed: MagicMock
) -> None:
    mock_search.return_value = []

    spec = ProductSpec(category="PPE", price_min=50.0, price_max=200.0)
    state = make_state(spec, location=(40.0, -74.0))
    from app.agents.nodes.retriever import retriever_node
    result = retriever_node(state)

    assert result["turn_status"] == "done"
    assert len(result["ranked_results"]) == 0
    assert mock_search.call_count == 5
    assert any("couldn't find" in m.content.lower() if isinstance(m, AIMessage) else False for m in result["messages"])
    msg_text = " ".join(m.content for m in result["messages"] if isinstance(m, AIMessage))
    assert "closest" not in msg_text.lower()
