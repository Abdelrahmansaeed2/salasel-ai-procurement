from sqlalchemy import select

from app.db.models import SupplierCatalog
from app.repositories.base import BaseRepository


class ProductRepository(BaseRepository):
    async def get_distinct_attributes(self, category: str) -> list[str]:
        query = select(
            SupplierCatalog.product_name,
            SupplierCatalog.sku,
            SupplierCatalog.unit_price,
        ).where(
            SupplierCatalog.category == category,
            SupplierCatalog.stock_available > 0,
        )
        result = await self._session.execute(query)
        rows = result.all()
        if not rows:
            return [f"No products found for category: {category}"]
        attrs: list[str] = []
        for product_name, sku, unit_price in rows:
            attrs.append(f"{product_name} (SKU: {sku}, ${unit_price:.2f})")
        return attrs

    def get_distinct_attributes_sync(self, category: str) -> list[str]:
        query = select(
            SupplierCatalog.product_name,
            SupplierCatalog.sku,
            SupplierCatalog.unit_price,
        ).where(
            SupplierCatalog.category == category,
            SupplierCatalog.stock_available > 0,
        )
        result = self._session.execute(query)
        rows = result.all()
        if not rows:
            return [f"No products found for category: {category}"]
        attrs: list[str] = []
        for product_name, sku, unit_price in rows:
            attrs.append(f"{product_name} (SKU: {sku}, ${unit_price:.2f})")
        return attrs
