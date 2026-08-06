from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder

from app.agents.state import InventoryState, ProductSpec, merge_spec
from app.core.llm import get_llm, invoke_with_json_retry

CONVERSATION_SYSTEM_PROMPT = """You are a product-discovery assistant for an inventory platform. Your job is to extract structured product requirements from the customer's messages and output them as a ProductSpec JSON object.

Extract or update these fields when the customer provides them:
- product_name: the item the customer is looking for, as they described it (e.g. "nitrile gloves", "KN95 masks")
- price_min / price_max: only when the customer states a budget
- required_attributes (key-value pairs the customer mentions, specific to the product)

Rules:
- product_name is required — ask nothing; just leave it null if not stated.
- Do NOT set the category field. The category is derived from our catalog by a lookup and must stay null in your output.
- If the customer's message is ambiguous about which product they want, or they ask what options exist, set needs_attribute_lookup=true instead of guessing.
- Do not decide whether the spec is "complete" — that is handled elsewhere.
- Always output a valid ProductSpec JSON object. Never respond conversationally."""


def conversation_node(state: InventoryState) -> dict:
    llm = get_llm(role="conversation").with_structured_output(ProductSpec, method="json_mode")  # type: ignore[call-overload]
    system_prompt = CONVERSATION_SYSTEM_PROMPT
    key_attribute = state.get("key_attribute")
    if key_attribute:
        system_prompt += (
            f"\n\nWhen the customer answers the question about their preferred "
            f"{key_attribute}, set required_attributes[\"{key_attribute}\"] to the value "
            f"they state."
        )
    prompt = ChatPromptTemplate.from_messages([
        ("system", system_prompt),
        MessagesPlaceholder(variable_name="messages"),
    ])
    chain = prompt | llm
    result = ProductSpec.model_validate(invoke_with_json_retry(chain, {"messages": state["messages"]}))
    merged = merge_spec(state["spec"], result)
    return {"spec": merged}
