import json
import logging
from typing import Annotated

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from pydantic import ValidationError

from app.api.v1.voice import _map_stt_errors, _read_audio
from app.schemas.order import OrderPipelineSchema, OrderRequest, OrderResponse
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


def parse_order_request(raw: str) -> OrderRequest:
    try:
        return OrderRequest.model_validate_json(raw)
    except (json.JSONDecodeError, ValidationError) as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail=f"Invalid order request: {exc}",
        ) from exc


@router.post("/voice/order", response_model=OrderResponse)
async def voice_order(
    audio: Annotated[UploadFile, File(...)],
    request: Annotated[str, Form(...)],
    stt: Annotated[SttClient, Depends(get_stt_client)] = None,
) -> OrderResponse:
    order_request = parse_order_request(request)
    data, filename = await _read_audio(audio)
    try:
        result = await transcribe_audio(data, filename, stt)
    except (AudioTooLargeError, UnsupportedFormatError, EmptyTranscriptError, SttProviderError) as exc:
        raise _map_stt_errors(exc)
    location: tuple[float, float] | None = None
    if order_request.location is not None:
        location = (order_request.location.lat, order_request.location.lon)
    try:
        return run_order_pipeline(OrderPipelineSchema(
            transcript=result.text,
            merchant_id=order_request.merchant_id,
            customer_location=location,
        ))
    except OrderGraphError as exc:
        logger.exception("order graph failed for merchant %s", order_request.merchant_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error occurred while generating the order: {exc!s}",
        )