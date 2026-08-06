import logging
from typing import Annotated

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from pydantic import BaseModel

from app.schemas.chat import ChatResponse
from app.services.chat_service import ChatGraphError, run_chat
from app.services.stt_service import (
    AudioTooLargeError,
    EmptyTranscriptError,
    SttClient,
    SttProviderError,
    UnsupportedFormatError,
    transcribe_audio,
)

logger = logging.getLogger(__name__)
router = APIRouter(tags=["voice"])


class TranscribeResponse(BaseModel):
    text: str
    language: str


def get_stt_client() -> SttClient:
    from app.services.stt_service import GroqSttClient

    return GroqSttClient()


def _parse_location(value: str | None) -> tuple[float, float] | None:
    if value is None or not value.strip():
        return None
    parts = value.split(",")
    if len(parts) != 2:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_CONTENT, detail="customer_location must be 'lat,lon'")
    try:
        return (float(parts[0].strip()), float(parts[1].strip()))
    except ValueError:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_CONTENT, detail="customer_location must be 'lat,lon'")


def _map_stt_errors(exc: Exception) -> HTTPException:
    if isinstance(exc, AudioTooLargeError):
        return HTTPException(status_code=status.HTTP_413_CONTENT_TOO_LARGE, detail=str(exc))
    if isinstance(exc, UnsupportedFormatError):
        return HTTPException(status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE, detail=str(exc))
    if isinstance(exc, EmptyTranscriptError):
        return HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_CONTENT, detail=str(exc))
    return HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(exc))


async def _read_audio(audio: UploadFile) -> tuple[bytes, str]:
    data = await audio.read()
    return data, audio.filename or "audio.m4a"


@router.post("/voice/transcribe", response_model=TranscribeResponse)
async def voice_transcribe(
    audio: Annotated[UploadFile, File(...)],
    stt: Annotated[SttClient, Depends(get_stt_client)],
) -> TranscribeResponse:
    data, filename = await _read_audio(audio)
    try:
        result = await transcribe_audio(data, filename, stt)
    except (AudioTooLargeError, UnsupportedFormatError, EmptyTranscriptError, SttProviderError) as exc:
        raise _map_stt_errors(exc)
    return TranscribeResponse(text=result.text, language=result.language)


@router.post("/voice/chat", response_model=ChatResponse)
async def voice_chat(
    audio: Annotated[UploadFile, File(...)],
    session_id: Annotated[str, Form(...)],
    customer_location: Annotated[str | None, Form()] = None,
    stt: Annotated[SttClient, Depends(get_stt_client)] = None,
) -> ChatResponse:
    data, filename = await _read_audio(audio)
    try:
        result = await transcribe_audio(data, filename, stt)
    except (AudioTooLargeError, UnsupportedFormatError, EmptyTranscriptError, SttProviderError) as exc:
        raise _map_stt_errors(exc)
    location = _parse_location(customer_location)
    try:
        return await run_chat(session_id, result.text, location)
    except ChatGraphError as exc:
        logger.exception("graph invocation failed for voice session %s", session_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error occurred while invoking the graph: {exc!s}",
        )
