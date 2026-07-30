from __future__ import annotations

from typing import Annotated, Any, Literal

from langgraph.graph.message import add_messages
from pydantic import BaseModel, model_validator
from typing_extensions import TypedDict


REQUIRED_FIELDS = ["category", "price_min", "price_max"]


class ProductSpec(BaseModel):
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
            if data.get("required_attributes") is None:
                data["required_attributes"] = {}
            if data.get("is_complete") is None:
                data["is_complete"] = False
        return data

    def to_query_text(self) -> str:
        parts = [f"category: {self.category}"]
        if self.price_min is not None:
            parts.append(f"min price: {self.price_min}")
        if self.price_max is not None:
            parts.append(f"max price: {self.price_max}")
        if self.required_attributes:
            for k, v in self.required_attributes.items():
                parts.append(f"{k}: {v}")
        return ", ".join(parts)


class Candidate(BaseModel):
    product_id: str
    supplier_id: str
    similarity_score: float = 0.0
    quality_score: float = 0.0
    distance_km: float = 0.0
    price: float = 0.0


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
    for field in REQUIRED_FIELDS:
        if getattr(spec, field) is None:
            return False
    return True
