from app.agents.state import ProductSpec, is_spec_complete, merge_spec


def test_is_spec_complete_all_none() -> None:
    spec = ProductSpec()
    assert is_spec_complete(spec) is False


def test_is_spec_complete_partial() -> None:
    spec = ProductSpec(category="electronics", price_min=100.0)
    assert is_spec_complete(spec) is False


def test_is_spec_complete_full() -> None:
    spec = ProductSpec(category="electronics", price_min=100.0, price_max=500.0)
    assert is_spec_complete(spec) is True


def test_merge_spec_takes_latest_non_null() -> None:
    current = ProductSpec(category="old", price_min=10.0, price_max=100.0)
    incoming = ProductSpec(price_min=20.0)
    merged = merge_spec(current, incoming)
    assert merged.category == "old"
    assert merged.price_min == 20.0
    assert merged.price_max == 100.0


def test_merge_spec_does_not_overwrite_with_none() -> None:
    current = ProductSpec(category="old", price_min=10.0, price_max=100.0)
    incoming = ProductSpec(price_max=None)
    merged = merge_spec(current, incoming)
    assert merged.price_max == 100.0


def test_merge_spec_required_attributes_merge() -> None:
    current = ProductSpec(required_attributes={"color": "red"})
    incoming = ProductSpec(required_attributes={"size": "large", "color": "blue"})
    merged = merge_spec(current, incoming)
    assert merged.required_attributes == {"color": "blue", "size": "large"}


def test_merge_spec_empty_incoming() -> None:
    current = ProductSpec(category="test", price_max=50.0)
    incoming = ProductSpec()
    merged = merge_spec(current, incoming)
    assert merged.category == "test"
    assert merged.price_max == 50.0
