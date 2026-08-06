from langgraph.checkpoint.redis import RedisSaver

from app.core.config import get_settings

_cm = None
_saver: RedisSaver | None = None


def get_checkpointer() -> RedisSaver:
    global _cm, _saver
    if _saver is None:
        settings = get_settings()
        _cm = RedisSaver.from_conn_string(str(settings.redis_url))
        _saver = _cm.__enter__()
        _saver.setup()
    return _saver


def close_checkpointer() -> None:
    global _cm, _saver
    if _cm is not None:
        _cm.__exit__(None, None, None)
        _cm = None
        _saver = None
