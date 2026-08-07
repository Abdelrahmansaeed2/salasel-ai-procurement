from unittest.mock import MagicMock

import pytest

from app.core.llm import invoke_with_json_retry


class JsonValidationError(Exception):
    pass


def _json_error(msg: str = "") -> JsonValidationError:
    return JsonValidationError("Error code: 400 - 'json_validate_failed' failed_generation: '' " + msg)


def test_retry_succeeds_after_transient_json_error() -> None:
    chain = MagicMock()
    chain.invoke.side_effect = [_json_error(), {"product_name": "gloves"}]

    result = invoke_with_json_retry(chain, {"messages": []})

    assert result == {"product_name": "gloves"}
    assert chain.invoke.call_count == 2


def test_retry_exhausted_raises() -> None:
    chain = MagicMock()
    chain.invoke.side_effect = _json_error()

    with pytest.raises(JsonValidationError):
        invoke_with_json_retry(chain, {"messages": []}, retries=2)

    assert chain.invoke.call_count == 3


def test_non_json_error_not_retried() -> None:
    chain = MagicMock()
    chain.invoke.side_effect = ValueError("some other error")

    with pytest.raises(ValueError):
        invoke_with_json_retry(chain, {"messages": []})

    assert chain.invoke.call_count == 1