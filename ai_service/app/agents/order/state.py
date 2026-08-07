from __future__ import annotations

from typing import TypedDict

from pydantic import BaseModel, Field

from app.schemas.order import OrderResponse


class ProductMatch(BaseModel):
    product_id: int
    supplier_id: int
    sku: str
    unit_price: float
    category: str
    attributes: dict[str, str] = Field(default_factory=dict)
    similarity_score: float = 0.0


class OrderLine(BaseModel):
    product_name: str
    quantity: int | None = None
    category: str | None = None
    requested_attributes: dict[str, str] = Field(default_factory=dict)
    price_bound_min: float | None = None
    price_bound_max: float | None = None

    matches: list[ProductMatch] = Field(default_factory=list)

    resolved_quantity: int = 1
    resolved_attributes: dict[str, str] = Field(default_factory=dict)
    resolved_unit_price: float | None = None

    matched: ProductMatch | None = None
    subtotal: float = 0.0
    error: str | None = None


class ExtractedOrders(BaseModel):
    products: list[OrderLine] = Field(default_factory=list)


class OrderState(TypedDict):
    transcript: str
    merchant_id: int | None
    customer_location: tuple[float, float] | None
    lines: list[OrderLine]
    order: OrderResponse | None
    errors: list[str]