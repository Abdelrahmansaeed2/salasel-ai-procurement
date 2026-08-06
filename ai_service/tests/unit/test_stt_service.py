import sys
from types import ModuleType, SimpleNamespace

import pytest

from app.core.config import Settings
from app.services.stt_service import (
    AudioTooLargeError,
    EmptyTranscriptError,
    GroqSttClient,
    SttProviderError,
    SttResult,
    UnsupportedFormatError,
    transcribe_audio,
)


class FakeSttClient:
    def __init__(self, result: SttResult | None = None, error: Exception | None = None) -> None:
        self.result = result or SttResult(text="I need PPE", language="en")
        self.error = error
        self.calls: list[tuple[bytes, str]] = []

    async def transcribe(self, data: bytes, filename: str) -> SttResult:
        self.calls.append((data, filename))
        if self.error:
            raise self.error
        return self.result


def install_fake_groq(monkeypatch: pytest.MonkeyPatch, *, raise_api_error: bool = False) -> list[dict]:
    module = ModuleType("groq")

    class APIError(Exception):
        pass

    module.APIError = APIError
    created: list[dict] = []

    class FakeTranscriptions:
        async def create(self, **request: object) -> SimpleNamespace:
            created.append(request)
            if raise_api_error:
                raise APIError("boom")
            return SimpleNamespace(text="hello", language="ar")

    class FakeAudio:
        def __init__(self) -> None:
            self.transcriptions = FakeTranscriptions()

    class FakeAsyncGroq:
        def __init__(self, api_key: str) -> None:
            self.api_key = api_key
            self.audio = FakeAudio()

    module.AsyncGroq = FakeAsyncGroq
    monkeypatch.setitem(sys.modules, "groq", module)
    return created


def _small_limit() -> Settings:
    return Settings(stt_max_audio_bytes=100)


async def test_transcribe_audio_returns_text_and_forwards_payload(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr("app.services.stt_service.get_settings", lambda: _small_limit())
    client = FakeSttClient()
    result = await transcribe_audio(b"audio-bytes", "voice.m4a", client)
    assert result == SttResult(text="I need PPE", language="en")
    assert client.calls == [(b"audio-bytes", "voice.m4a")]


async def test_transcribe_audio_rejects_empty_payload(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr("app.services.stt_service.get_settings", lambda: _small_limit())
    with pytest.raises(EmptyTranscriptError):
        await transcribe_audio(b"", "voice.m4a", FakeSttClient())


async def test_transcribe_audio_rejects_oversized_payload(monkeypatch: pytest.MonkeyPatch) -> None:
    settings = Settings(stt_max_audio_bytes=5)
    monkeypatch.setattr("app.services.stt_service.get_settings", lambda: settings)
    with pytest.raises(AudioTooLargeError):
        await transcribe_audio(b"123456", "voice.m4a", FakeSttClient())


async def test_transcribe_audio_rejects_unsupported_extension(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr("app.services.stt_service.get_settings", lambda: _small_limit())
    with pytest.raises(UnsupportedFormatError):
        await transcribe_audio(b"audio-bytes", "voice.exe", FakeSttClient())


async def test_transcribe_audio_rejects_empty_transcript(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr("app.services.stt_service.get_settings", lambda: _small_limit())
    client = FakeSttClient(result=SttResult(text="   ", language="en"))
    with pytest.raises(EmptyTranscriptError):
        await transcribe_audio(b"audio-bytes", "voice.m4a", client)


async def test_groq_client_builds_request_with_timeout(monkeypatch: pytest.MonkeyPatch) -> None:
    created = install_fake_groq(monkeypatch)
    settings = Settings(stt_model="whisper-large-v3-turbo", stt_timeout=15, llm_groq_api_key="key")
    result = await GroqSttClient(settings).transcribe(b"bytes", "audio.m4a")
    assert result == SttResult(text="hello", language="ar")
    request = created[0]
    assert request["model"] == "whisper-large-v3-turbo"
    assert request["file"] == ("audio.m4a", b"bytes")
    assert request["timeout"] == 15
    assert request["temperature"] == 0.0
    assert "language" not in request


async def test_groq_client_forwards_configured_language(monkeypatch: pytest.MonkeyPatch) -> None:
    created = install_fake_groq(monkeypatch)
    settings = Settings(stt_language="ar", llm_groq_api_key="key")
    await GroqSttClient(settings).transcribe(b"bytes", "audio.m4a")
    assert created[0]["language"] == "ar"


async def test_groq_client_maps_api_error(monkeypatch: pytest.MonkeyPatch) -> None:
    install_fake_groq(monkeypatch, raise_api_error=True)
    settings = Settings(llm_groq_api_key="key")
    with pytest.raises(SttProviderError):
        await GroqSttClient(settings).transcribe(b"bytes", "audio.m4a")
