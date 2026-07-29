from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import Session


class BaseRepository:
    def __init__(self, session: AsyncSession | Session) -> None:
        self._session = session
