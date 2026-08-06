import logging
from typing import Annotated

from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile, status

from app.api.v1.voice import _map_stt_errors, _read_audio
from app.schemas.order import OrderPipelineSchema, OrderResponse, OrderTextRequest
from app.services.order_service import OrderGraphError, run_order_pipeline
from app.services.stt_service import (
    AudioTooLargeError,
    EmptyTranscriptError,
    SttClient,
    SttProviderError,
    UnsupportedFormatError,
    transcribe_audio,
)

logger = logging.getLogger(__name__)
router = APIRouter(tags=["order"])


def get_stt_client() -> SttClient:
    from app.services.stt_service import GroqSttClient

    return GroqSttClient()


def _location_or_422(lat: float | None, lon: float | None) -> tuple[float, float] | None:
    if lat is not None or lon is not None:
        if lat is None or lon is None:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
                detail="lat and lon must be provided together",
            )
        return (lat, lon)
    return None


def _invoke_order_pipeline(
    merchant_id: int,
    transcript: str,
    location: tuple[float, float] | None,
) -> OrderResponse:
    try:
        return run_order_pipeline(OrderPipelineSchema(
            transcript=transcript,
            merchant_id=merchant_id,
            customer_location=location,
        ))
    except OrderGraphError as exc:
        logger.exception("order graph failed for merchant %s", merchant_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error occurred while generating the order: {exc!s}",
        )


@router.post("/voice/order/{merchant_id}", response_model=OrderResponse)
async def voice_order(
    merchant_id: int,
    audio: Annotated[UploadFile, File(...)],
    lat: Annotated[float | None, Query()] = None,
    lon: Annotated[float | None, Query()] = None,
    stt: Annotated[SttClient, Depends(get_stt_client)] = None,
) -> OrderResponse:
    location = _location_or_422(lat, lon)
    data, filename = await _read_audio(audio)
    try:
        result = await transcribe_audio(data, filename, client=stt)
    except (AudioTooLargeError, UnsupportedFormatError, EmptyTranscriptError, SttProviderError) as exc:
        raise _map_stt_errors(exc)
    return _invoke_order_pipeline(merchant_id, result.text, location)


@router.post("/order/{merchant_id}", response_model=OrderResponse)
async def text_order(
    merchant_id: int,
    request: OrderTextRequest,
) -> OrderResponse:
    if not request.transcript.strip():
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail="transcript cannot be empty",
        )
    location = _location_or_422(request.lat, request.lon)
    return _invoke_order_pipeline(merchant_id, request.transcript, location)
