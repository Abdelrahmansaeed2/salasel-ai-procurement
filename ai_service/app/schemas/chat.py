from pydantic import BaseModel

from app.agents.state import Candidate, ProductSpec


class ChatRequest(BaseModel):
    session_id: str
    message: str
    customer_location: tuple[float, float] | None = None


class VoiceChatRequest(BaseModel):
    session_id: str
    customer_location: tuple[float, float] | None = None


class ChatResponse(BaseModel):
    response: str
    spec: ProductSpec
    turn_status: str
    missing_fields: list[str]
    ranked_results: list[Candidate]
