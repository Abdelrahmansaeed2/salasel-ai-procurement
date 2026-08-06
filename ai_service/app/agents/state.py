from __future__ import annotations

from typing import Annotated, Any, Literal, NotRequired

from langgraph.graph.message import add_messages
from pydantic import BaseModel, model_validator
from typing_extensions import TypedDict

REQUIRED_FIELDS = ["product_name"]


class ProductSpec(BaseModel):
    product_name: str | None = None
    category: str | None = None
    price_min: float | None = None
    price_max: float | None = None
    required_attributes: dict[str, str] = {}
    is_complete: bool = False
    needs_attribute_lookup: bool = False

    @model_validator(mode="before")
    @classmethod
    def coerce_none_to_defaults(cls, data: Any) -> Any:
        if isinstance(data, dict):
            # LangGraph's checkpointer (RedisSaver) serializes pydantic models into
            # a langchain "constructor" dict: {"lc":2,"type":"constructor","kwargs":{...}}.
            # model_validate() on that dict silently drops every field, which wipes
            # category/required_attributes on every resumed turn. Unpack kwargs first.
            if data.get("type") == "constructor" and isinstance(data.get("kwargs"), dict):
                data = data["kwargs"]
            if data.get("required_attributes") is None:
                data["required_attributes"] = {}
            if data.get("is_complete") is None:
                data["is_complete"] = False
        return data

    def to_query_text(self) -> str:
        parts = [self.product_name or self.category or ""]
        if self.category and self.product_name:
            parts.append(f"category: {self.category}")
        if self.price_min is not None:
            parts.append(f"min price: {self.price_min}")
        if self.price_max is not None:
            parts.append(f"max price: {self.price_max}")
        if self.required_attributes:
            for k, v in self.required_attributes.items():
                parts.append(f"{k}: {v}")
        return ", ".join(p for p in parts if p)


class Candidate(BaseModel):
    product_id: str
    supplier_id: str
    similarity_score: float = 0.0
    quality_score: float = 0.0
    distance_km: float = 0.0
    price: float = 0.0
    product_name: str | None = None
    sku: str | None = None
    category: str | None = None
    description: str | None = None
    attributes: dict[str, str] = {}
    in_stock: bool | None = None


class InventoryState(TypedDict):
    messages: Annotated[list, add_messages]
    spec: ProductSpec
    customer_location: tuple[float, float] | None
    candidates: list[Candidate]
    ranked_results: list[Candidate]
    rejected_ids: list[str]
    rank_weights: dict[str, float]
    missing_fields: list[str]
    turn_status: Literal["ask", "retrieve", "confirm", "done", "rerank"]
    interrupt_action: str
    resolved_candidates: NotRequired[list[dict]]
    key_attribute: NotRequired[str | None]
    attribute_options: NotRequired[list[str]]
    attribute_prompt: NotRequired[str | None]
    key_attribute_asked: NotRequired[bool]
    pending_attributes: NotRequired[list[str]]


def merge_spec(current: ProductSpec | dict, incoming: ProductSpec) -> ProductSpec:
    if not isinstance(current, ProductSpec):
        current = ProductSpec.model_validate(current)
    merged = current.model_copy()
    for field in ProductSpec.model_fields:
        incoming_val = getattr(incoming, field)
        if incoming_val is None:
            continue
        if field == "required_attributes":
            merged.required_attributes.update(
                {k: v for k, v in incoming_val.items() if v}
            )
        elif incoming_val != getattr(merged, field):
            setattr(merged, field, incoming_val)
    return merged


def is_spec_complete(spec: ProductSpec) -> bool:
    return not missing_fields(spec)


def missing_fields(spec: ProductSpec) -> list[str]:
    """Fields the customer has not yet supplied, one entry per follow-up question.

    ``price`` counts as a single missing field (asked as one "budget" question)
    and is satisfied when either bound is set.
    """
    missing = [
        f for f in REQUIRED_FIELDS
        if _is_blank(getattr(spec, f, None))
    ]
    if spec.price_min is None and spec.price_max is None:
        missing.append("price")
    return missing


def _is_blank(value: Any) -> bool:
    return value is None or (isinstance(value, str) and not value.strip())
