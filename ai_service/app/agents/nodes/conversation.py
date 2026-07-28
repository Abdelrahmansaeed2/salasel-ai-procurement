from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder

from app.agents.state import InventoryState, ProductSpec, merge_spec
from app.core.llm import get_llm

CONVERSATION_SYSTEM_PROMPT = """You are a product-discovery assistant for an inventory platform. Your job is to extract structured product requirements from the customer's messages and output them as a ProductSpec JSON object.

Extract or update these fields when the customer provides them:
- category
- price_min / price_max
- required_attributes (key-value pairs specific to the category)

Rules:
- Do not invent values the customer didn't state. Set unknown fields to null.
- If the customer's message is ambiguous about which attributes apply to their category, set needs_attribute_lookup=true instead of guessing.
- Do not decide whether the spec is "complete" — that is handled elsewhere.
- Always output a valid ProductSpec JSON object. Never respond conversationally."""


def conversation_node(state: InventoryState) -> dict:
    llm = get_llm(role="conversation").with_structured_output(ProductSpec, method="json_mode")  # type: ignore[call-overload]
    prompt = ChatPromptTemplate.from_messages([
        ("system", CONVERSATION_SYSTEM_PROMPT),
        MessagesPlaceholder(variable_name="messages"),
    ])
    chain = prompt | llm
    result = ProductSpec.model_validate(chain.invoke({"messages": state["messages"]}))
    merged = merge_spec(state["spec"], result)
    return {"spec": merged}
