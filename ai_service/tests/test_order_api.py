from fastapi.testclient import TestClient

from app.main import app


def _voice_url(merchant_id: int = 42) -> str:
    return f"/api/v1/voice/order/{merchant_id}"


def test_voice_order_endpoint_returns_schema(monkeypatch) -> None:
    import app.api.v1.order as order_module
    from app.schemas.order import OrderPipelineSchema, OrderResponse, OrderSplit
    from app.services.stt_service import SttResult

    captured = {}

    async def fake_transcribe(data: bytes, filename: str, client=None):
        return SttResult(text="I need 5 boxes of nitrile gloves", language="en")

    def fake_pipeline(request: OrderPipelineSchema):
        captured["merchant_id"] = request.merchant_id
        captured["location"] = request.customer_location
        return OrderResponse(
            merchant_id=request.merchant_id,
            total_order_cost=18.75,
            splits=[OrderSplit(supplier_id=10, sku="NG-M", quantity_ordered=5, sub_total_cost=18.75)],
        )

    monkeypatch.setattr(order_module, "transcribe_audio", fake_transcribe)
    monkeypatch.setattr(order_module, "run_order_pipeline", fake_pipeline)

    response = TestClient(app).post(
        _voice_url(42),
        params={"lat": 30.0, "lon": 31.0},
        files={"audio": ("order.wav", b"RIFF-test-audio", "audio/wav")},
    )

    assert response.status_code == 200
    body = response.json()
    assert body["merchant_id"] == 42
    assert body["total_order_cost"] == 18.75
    assert body["splits"][0]["sku"] == "NG-M"
    assert body["splits"][0]["quantity_ordered"] == 5
    assert captured["merchant_id"] == 42
    assert captured["location"] == (30.0, 31.0)


def test_voice_order_endpoint_without_location(monkeypatch) -> None:
    import app.api.v1.order as order_module
    from app.schemas.order import OrderPipelineSchema, OrderResponse
    from app.services.stt_service import SttResult

    captured = {}

    async def fake_transcribe(data: bytes, filename: str, client=None):
        return SttResult(text="I need gloves", language="en")

    def fake_pipeline(request: OrderPipelineSchema):
        captured["location"] = request.customer_location
        return OrderResponse(merchant_id=request.merchant_id)

    monkeypatch.setattr(order_module, "transcribe_audio", fake_transcribe)
    monkeypatch.setattr(order_module, "run_order_pipeline", fake_pipeline)

    response = TestClient(app).post(
        _voice_url(42),
        files={"audio": ("order.wav", b"RIFF-test-audio", "audio/wav")},
    )

    assert response.status_code == 200
    assert captured["location"] is None


def test_voice_order_endpoint_partial_location() -> None:
    response = TestClient(app).post(
        _voice_url(42),
        params={"lat": 30.0},
        files={"audio": ("order.wav", b"RIFF-test-audio", "audio/wav")},
    )
    assert response.status_code == 422


def test_voice_order_endpoint_requires_audio() -> None:
    response = TestClient(app).post(_voice_url(42))
    assert response.status_code == 422


def test_voice_order_endpoint_non_integer_merchant() -> None:
    response = TestClient(app).post(
        "/api/v1/voice/order/abc",
        files={"audio": ("order.wav", b"RIFF-test-audio", "audio/wav")},
    )
    assert response.status_code == 422


def test_voice_order_endpoint_missing_merchant_path() -> None:
    response = TestClient(app).post(
        "/api/v1/voice/order",
        files={"audio": ("order.wav", b"RIFF-test-audio", "audio/wav")},
    )
    assert response.status_code == 404
