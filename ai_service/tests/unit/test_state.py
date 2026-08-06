from app.agents.state import ProductSpec, is_spec_complete, merge_spec, missing_fields


def test_is_spec_complete_none() -> None:
    assert is_spec_complete(ProductSpec()) is False


def test_missing_fields_empty_spec() -> None:
    assert missing_fields(ProductSpec()) == ["product_name", "price"]


def test_missing_fields_product_name_only() -> None:
    assert missing_fields(ProductSpec(product_name="gloves")) == ["price"]


def test_missing_fields_price_satisfied_by_either_bound() -> None:
    assert missing_fields(ProductSpec(product_name="gloves", price_max=50.0)) == []
    assert missing_fields(ProductSpec(product_name="gloves", price_min=10.0)) == []


def test_is_spec_complete_blank() -> None:
    assert is_spec_complete(ProductSpec(product_name="   ")) is False


def test_is_spec_complete_product_name_only() -> None:
    assert is_spec_complete(ProductSpec(product_name="gloves")) is False


def test_is_spec_complete_with_product_name_and_price() -> None:
    assert is_spec_complete(ProductSpec(product_name="gloves", price_max=50.0)) is True
    assert is_spec_complete(ProductSpec(product_name="gloves", price_min=10.0)) is True


def test_is_complete_implies_is_spec_complete_true() -> None:
    spec = ProductSpec(product_name="gloves", category="PPE", price_max=5.0)
    assert is_spec_complete(spec) is True


def test_merge_spec_takes_latest_non_null() -> None:
    current = ProductSpec(product_name="old", price_min=10.0, price_max=100.0)
    incoming = ProductSpec(price_min=20.0)
    merged = merge_spec(current, incoming)
    assert merged.product_name == "old"
    assert merged.price_min == 20.0
    assert merged.price_max == 100.0


def test_merge_spec_does_not_overwrite_with_none() -> None:
    current = ProductSpec(product_name="gloves", price_max=100.0)
    incoming = ProductSpec(price_max=None)
    merged = merge_spec(current, incoming)
    assert merged.price_max == 100.0


def test_merge_spec_product_name_takes_latest() -> None:
    current = ProductSpec(product_name="gloves")
    incoming = ProductSpec(product_name="masks")
    merged = merge_spec(current, incoming)
    assert merged.product_name == "masks"


def test_merge_spec_required_attributes_merge() -> None:
    current = ProductSpec(required_attributes={"color": "red"})
    incoming = ProductSpec(required_attributes={"size": "large", "color": "blue"})
    merged = merge_spec(current, incoming)
    assert merged.required_attributes == {"color": "blue", "size": "large"}


def test_merge_spec_empty_incoming() -> None:
    current = ProductSpec(product_name="test", price_max=50.0)
    merged = merge_spec(current, ProductSpec())
    assert merged.product_name == "test"
    assert merged.price_max == 50.0


def test_to_query_text_prefers_category_when_set() -> None:
    spec = ProductSpec(product_name="gloves", category="PPE", price_max=5.0)
    text = spec.to_query_text()
    assert "gloves" in text
    assert "category: PPE" in text
    assert "max price: 5.0" in text


def test_validate_langchain_constructor_dict() -> None:
    constructor = {
        "lc": 2,
        "type": "constructor",
        "id": ["app", "agents", "state", "ProductSpec"],
        "kwargs": {
            "product_name": "nitrile gloves",
            "category": "PPE",
            "price_min": None,
            "price_max": None,
            "required_attributes": {"size": "any size"},
            "is_complete": False,
            "needs_attribute_lookup": False,
        },
    }
    spec = ProductSpec.model_validate(constructor)
    assert spec.product_name == "nitrile gloves"
    assert spec.category == "PPE"
    assert spec.required_attributes == {"size": "any size"}
