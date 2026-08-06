from pydantic import BaseModel, Field


class OrderPipelineSchema(BaseModel):
    merchant_id: int | None = None
    customer_location: tuple[float, float] | None = None
    transcript: str


class OrderSplit(BaseModel):
    supplier_id: int
    sku: str
    quantity_ordered: int
    sub_total_cost: float


class OrderResponse(BaseModel):
    merchant_id: int | None = None
    total_order_cost: float = 0.0
    splits: list[OrderSplit] = Field(default_factory=list)
    unresolved: list[str] = Field(default_factory=list)