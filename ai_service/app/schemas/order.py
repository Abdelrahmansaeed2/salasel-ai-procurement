from pydantic import BaseModel, Field


class OrderPipelineSchema(BaseModel):
    merchant_id: int | None = None
    customer_location: tuple[float, float] | None = None
    transcript: str


class OrderTextRequest(BaseModel):
    transcript: str
    lat: float | None = None
    lon: float | None = None


class OrderItem(BaseModel):
    product_id: int
    name: str
    category: str
    quantity: int
    unit: str
    unit_price: float
    sub_total: float


class OrderSplit(BaseModel):
    supplier_id: int
    items: list[OrderItem] = Field(default_factory=list)
    sub_total_cost: float
    delivery_time_days: int = 1


class OrderResponse(BaseModel):
    merchant_id: int | None = None
    transcript: str | None = None
    total_order_cost: float = 0.0
    splits: list[OrderSplit] = Field(default_factory=list)
    unresolved: list[str] = Field(default_factory=list)
    risk_alerts: list[dict] = Field(default_factory=list)