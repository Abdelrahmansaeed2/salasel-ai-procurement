import logging
from dataclasses import dataclass
from pathlib import Path
from typing import Protocol

from app.core.config import Settings, get_settings

logger = logging.getLogger(__name__)

SUPPORTED_AUDIO_EXTENSIONS = {"m4a", "mp3", "wav", "webm", "ogg", "flac", "mp4", "mpeg", "mpga"}


class SttError(Exception):
    """Base error for speech-to-text failures."""


class AudioTooLargeError(SttError):
    pass


class UnsupportedFormatError(SttError):
    pass


class EmptyTranscriptError(SttError):
    pass


class SttProviderError(SttError):
    pass


@dataclass(frozen=True)
class SttResult:
    text: str
    language: str = ""


class SttClient(Protocol):
    async def transcribe(self, data: bytes, filename: str) -> SttResult: ...


class GroqSttClient:
    def __init__(self, settings: Settings | None = None) -> None:
        self._settings = settings or get_settings()

    async def transcribe(self, data: bytes, filename: str) -> SttResult:
        from groq import APIError, AsyncGroq

        api_key = self._settings.stt_api_key or self._settings.llm_groq_api_key
        client = AsyncGroq(api_key=api_key)
        request: dict = {
            "file": (filename, data),
            "model": self._settings.stt_model,
            "temperature": 0.0,
            "response_format": "json",
            "prompt": "Egyptian Arabic dialect. انا عايز كرتونة لبن",
            "timeout": self._settings.stt_timeout,
        }
        if self._settings.stt_language:
            request["language"] = self._settings.stt_language
        logger.info(
            "stt transcribe request model=%s language=%r bytes=%d", self._settings.stt_model,
            self._settings.stt_language or "auto", len(data),
        )
        try:
            response = await client.audio.transcriptions.create(**request)
        except APIError as exc:
            logger.exception("groq transcription failed")
            raise SttProviderError(f"Speech-to-text provider error: {exc}") from exc
        except Exception as exc:
            logger.exception("unexpected transcription failure")
            raise SttProviderError(f"Unexpected speech-to-text failure: {exc}") from exc
        text = (response.text or "").strip()
        language = getattr(response, "language", "") or ""
        logger.info("stt transcribe complete language=%r text=%r", language, text)
        return SttResult(text=text, language=language)


async def transcribe_audio(data: bytes, filename: str, client: SttClient) -> SttResult:
    """Validate the audio payload and transcribe it via the injected client.

    Raises AudioTooLargeError, UnsupportedFormatError, or EmptyTranscriptError
    for client-correctable inputs; provider failures surface as SttProviderError.
    """
    extension = Path(filename).suffix.lower().lstrip(".")
    if not data:
        raise EmptyTranscriptError("Empty audio payload")
    if len(data) > get_settings().stt_max_audio_bytes:
        raise AudioTooLargeError(
            f"Audio file exceeds the {get_settings().stt_max_audio_bytes} byte limit"
        )
    if extension not in SUPPORTED_AUDIO_EXTENSIONS:
        raise UnsupportedFormatError(
            f"Unsupported audio format '.{extension}'. Supported: {sorted(SUPPORTED_AUDIO_EXTENSIONS)}"
        )
    result = await client.transcribe(data, filename)
    if not result.text.strip():
        raise EmptyTranscriptError("No speech detected in the audio")
    return result
