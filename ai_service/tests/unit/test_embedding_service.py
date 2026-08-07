import pytest

from app.services.embedding_service import embed


@pytest.mark.asyncio
async def test_embed_returns_vector() -> None:
    vector = await embed("test product description")
    assert isinstance(vector, list)
    assert len(vector) > 0
    assert all(isinstance(v, float) for v in vector)


@pytest.mark.asyncio
async def test_embed_consistent_dimension() -> None:
    v1 = await embed("hello world")
    v2 = await embed("another text")
    assert len(v1) == len(v2)
