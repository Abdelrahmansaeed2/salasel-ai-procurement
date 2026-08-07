from pydantic import BaseModel


class ProductUpsert(BaseModel):
    product_id: int
    supplier_id: int
    product_name: str
    sku: str = ""
    category: str = ""
    description: str = ""
    attributes: dict[str, str] = {}
    price: float = 0.0
    lat: float = 0.0
    lon: float = 0.0
    in_stock: bool = True


class ProductUpsertBatch(BaseModel):
    products: list[ProductUpsert]


class SupplierQualityMetrics(BaseModel):
    supplier_id: int
    review_count: int = 0
    average_rating: float = 0.0
    on_time_delivery_rate: float = 0.0
    defect_rate: float = 0.0


class QualityMetricsBatch(BaseModel):
    metrics: list[SupplierQualityMetrics]
