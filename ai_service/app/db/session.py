from collections.abc import AsyncIterator

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncEngine, AsyncSession, async_sessionmaker, create_async_engine

from app.core.config import Settings, get_settings

_engine: AsyncEngine | None = None
_sessionmaker: async_sessionmaker[AsyncSession] | None = None


def get_engine(settings: Settings | None = None) -> AsyncEngine:
    global _engine
    if _engine is None:
        resolved = settings or get_settings()
        _engine = create_async_engine(
            resolved.database_url,
            pool_size=resolved.db_pool_size,
            max_overflow=resolved.db_max_overflow,
            pool_pre_ping=True,
            connect_args={"timeout": resolved.db_command_timeout_seconds},
        )
    return _engine


def get_sessionmaker(settings: Settings | None = None) -> async_sessionmaker[AsyncSession]:
    global _sessionmaker
    if _sessionmaker is None:
        _sessionmaker = async_sessionmaker(
            bind=get_engine(settings),
            class_=AsyncSession,
            expire_on_commit=False,
        )
    return _sessionmaker


async def get_db_session() -> AsyncIterator[AsyncSession]:
    async with get_sessionmaker()() as session:
        yield session


async def check_database_connection(settings: Settings | None = None) -> bool:
    try:
        async with get_engine(settings).connect() as connection:
            await connection.execute(text("SELECT 1"))
        return True
    except Exception:
        return False
