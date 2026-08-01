from unittest.mock import AsyncMock, MagicMock

import pytest

from app.repositories.product_repository import ProductRepository


@pytest.mark.asyncio
async def test_get_distinct_attributes_returns_product_list() -> None:
    session = AsyncMock()
    result = MagicMock()
    result.all.return_value = [
        ("Nitrile Gloves Medium", "PPE-GLOVES-NITRILE-M", 3.75),
        ("Safety Goggles", "PPE-GOGGLES-U", 5.50),
    ]
    session.execute = AsyncMock(return_value=result)

    repo = ProductRepository(session)
    attrs = await repo.get_distinct_attributes("PPE")

    assert len(attrs) == 2
    assert "Nitrile Gloves Medium" in attrs[0]
    assert "PPE-GLOVES-NITRILE-M" in attrs[0]
    assert "$3.75" in attrs[0]
    assert "Safety Goggles" in attrs[1]


@pytest.mark.asyncio
async def test_get_distinct_attributes_no_results() -> None:
    session = AsyncMock()
    result = MagicMock()
    result.all.return_value = []
    session.execute = AsyncMock(return_value=result)

    repo = ProductRepository(session)
    attrs = await repo.get_distinct_attributes("Unknown")

    assert len(attrs) == 1
    assert "No products found" in attrs[0]
