from unittest.mock import patch

import pytest

from app.schemas.order import OrderPipelineSchema, OrderResponse, OrderSplit
from app.services.order_service import OrderGraphError, run_order_pipeline


@patch("app.services.order_service.get_compiled_graph")
def test_run_order_pipeline_accepts_order_request(mock_graph) -> None:
    fake = mock_graph.return_value
    fake.invoke.return_value = {
        "order": OrderResponse(
            merchant_id=5,
            total_order_cost=12.5,
            splits=[OrderSplit(supplier_id=1, sku="NG-M", quantity_ordered=5, sub_total_cost=12.5)],
        )
    }

    result = run_order_pipeline(OrderPipelineSchema(
        transcript="5 boxes of gloves",
        merchant_id=5,
        customer_location=(30.0, 31.0),
    ))

    assert isinstance(result, OrderResponse)
    assert result.merchant_id == 5
    assert result.total_order_cost == 12.5
    assert result.splits[0].sku == "NG-M"


@patch("app.services.order_service.get_compiled_graph")
def test_run_order_pipeline_raises_when_no_order(mock_graph) -> None:
    fake = mock_graph.return_value
    fake.invoke.return_value = {"order": None}

    with pytest.raises(OrderGraphError):
        run_order_pipeline(OrderPipelineSchema(transcript="gloves", merchant_id=1))