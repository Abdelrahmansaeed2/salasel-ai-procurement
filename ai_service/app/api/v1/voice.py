import json
import logging
from typing import Annotated

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from pydantic import BaseModel, ValidationError

from app.schemas.chat import ChatResponse, VoiceChatRequest
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


def parse_voice_chat_request(raw: str) -> VoiceChatRequest:
    try:
        return VoiceChatRequest.model_validate_json(raw)
    except (json.JSONDecodeError, ValidationError) as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail=f"Invalid chat request: {exc}",
        ) from exc


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
    request: Annotated[str, Form(...)],
    stt: Annotated[SttClient, Depends(get_stt_client)] = None,
) -> ChatResponse:
    chat_request = parse_voice_chat_request(request)
    data, filename = await _read_audio(audio)
    try:
        result = await transcribe_audio(data, filename, stt)
    except (AudioTooLargeError, UnsupportedFormatError, EmptyTranscriptError, SttProviderError) as exc:
        raise _map_stt_errors(exc)
    try:
        return await run_chat(chat_request.session_id, result.text, chat_request.customer_location)
    except ChatGraphError as exc:
        logger.exception("graph invocation failed for voice session %s", chat_request.session_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error occurred while invoking the graph: {exc!s}",
        )
