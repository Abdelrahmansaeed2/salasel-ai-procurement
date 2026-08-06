from pydantic import BaseModel, ConfigDict, Field


class OrderLocation(BaseModel):
    lat: float
    lon: float


class OrderRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    merchant_id: int = Field(alias="merchantId")
    location: OrderLocation | None = Field(default=None, alias="location")


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