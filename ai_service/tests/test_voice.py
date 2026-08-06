import pytest
from fastapi.testclient import TestClient

from app.agents.state import ProductSpec
from app.api.v1.voice import get_stt_client
from app.main import app
from app.schemas.chat import ChatResponse
from app.services.stt_service import (
    AudioTooLargeError,
    EmptyTranscriptError,
    SttProviderError,
    SttResult,
    UnsupportedFormatError,
)


class FakeSttClient:
    def __init__(self, text: str = "I need PPE with budget 2 to 5 dollars") -> None:
        self.text = text
        self.received: tuple[bytes, str] | None = None

    async def transcribe(self, data: bytes, filename: str) -> SttResult:
        self.received = (data, filename)
        return SttResult(text=self.text, language="en")


def _post_voice_chat(*, data: dict | None = None, files: dict | None = None) -> object:
    files = files or {"audio": ("voice.m4a", b"fakeaudio", "audio/mp4")}
    data = data or {"request": '{"session_id": "s"}'}
    return TestClient(app).post("/api/v1/voice/chat", files=files, data=data)


def test_voice_transcribe_returns_text() -> None:
    stt = FakeSttClient()
    app.dependency_overrides[get_stt_client] = lambda: stt
    try:
        response = TestClient(app).post(
            "/api/v1/voice/transcribe",
            files={"audio": ("voice.m4a", b"fakeaudio", "audio/mp4")},
        )
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 200
    assert response.json() == {"text": "I need PPE with budget 2 to 5 dollars", "language": "en"}
    assert stt.received == (b"fakeaudio", "voice.m4a")


def test_voice_chat_transcribes_then_runs_chat(monkeypatch: pytest.MonkeyPatch) -> None:
    import app.api.v1.voice as voice_module

    calls: dict = {}

    async def fake_run_chat(session_id: str, message: str, customer_location=None) -> ChatResponse:
        calls["session_id"] = session_id
        calls["message"] = message
        calls["customer_location"] = customer_location
        return ChatResponse(
            response="Here are your matches",
            spec=ProductSpec(),
            turn_status="ask",
            missing_fields=[],
            ranked_results=[],
        )

    monkeypatch.setattr(voice_module, "run_chat", fake_run_chat)
    stt = FakeSttClient()
    app.dependency_overrides[get_stt_client] = lambda: stt
    try:
        response = _post_voice_chat(
            data={"request": '{"session_id": "voice-1", "customer_location": [30.0444, 31.2357]}'}
        )
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 200
    assert calls["session_id"] == "voice-1"
    assert calls["message"] == "I need PPE with budget 2 to 5 dollars"
    assert calls["customer_location"] == (30.0444, 31.2357)
    assert response.json()["response"] == "Here are your matches"


def test_voice_chat_runs_chat_without_location(monkeypatch: pytest.MonkeyPatch) -> None:
    import app.api.v1.voice as voice_module

    calls: dict = {}

    async def fake_run_chat(session_id: str, message: str, customer_location=None) -> ChatResponse:
        calls["customer_location"] = customer_location
        return ChatResponse(
            response="Need your location", spec=ProductSpec(), turn_status="ask",
            missing_fields=[], ranked_results=[],
        )

    monkeypatch.setattr(voice_module, "run_chat", fake_run_chat)
    stt = FakeSttClient()
    app.dependency_overrides[get_stt_client] = lambda: stt
    try:
        response = _post_voice_chat(data={"request": '{"session_id": "voice-2"}'})
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 200
    assert calls["customer_location"] is None


def test_voice_chat_rejects_bad_location_format(monkeypatch: pytest.MonkeyPatch) -> None:
    import app.api.v1.voice as voice_module

    async def fake_run_chat(session_id: str, message: str, customer_location=None) -> ChatResponse:
        raise AssertionError("run_chat should not be reached")

    monkeypatch.setattr(voice_module, "run_chat", fake_run_chat)
    stt = FakeSttClient()
    app.dependency_overrides[get_stt_client] = lambda: stt
    try:
        response = _post_voice_chat(
            data={"request": '{"session_id": "voice-3", "customer_location": "cairo"}'}
        )
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 422


def test_voice_chat_rejects_invalid_request_json(monkeypatch: pytest.MonkeyPatch) -> None:
    import app.api.v1.voice as voice_module

    async def fake_run_chat(session_id: str, message: str, customer_location=None) -> ChatResponse:
        raise AssertionError("run_chat should not be reached")

    monkeypatch.setattr(voice_module, "run_chat", fake_run_chat)
    stt = FakeSttClient()
    app.dependency_overrides[get_stt_client] = lambda: stt
    try:
        response = _post_voice_chat(data={"request": "not json"})
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 422


@pytest.mark.parametrize(
    ("error", "expected_status"),
    [
        (AudioTooLargeError("too big"), 413),
        (UnsupportedFormatError("bad format"), 415),
        (EmptyTranscriptError("silence"), 422),
        (SttProviderError("provider down"), 500),
    ],
)
def test_voice_chat_maps_stt_errors(monkeypatch: pytest.MonkeyPatch, error: Exception, expected_status: int) -> None:
    import app.api.v1.voice as voice_module

    async def raise_error(data: bytes, filename: str, client: object) -> None:
        raise error

    monkeypatch.setattr(voice_module, "transcribe_audio", raise_error)
    stt = FakeSttClient()
    app.dependency_overrides[get_stt_client] = lambda: stt
    try:
        response = _post_voice_chat()
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == expected_status
