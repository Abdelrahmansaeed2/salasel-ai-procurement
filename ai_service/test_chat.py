import asyncio
from langchain_core.messages import HumanMessage
from app.agents.graph import get_compiled_graph
from app.agents.state import InventoryState, ProductSpec
from langchain_core.runnables import RunnableConfig

async def main():
    config: RunnableConfig = {"configurable": {"thread_id": "debug-1"}}
    input_msg = InventoryState(
        messages=[HumanMessage(content="I need gloves")],
        spec=ProductSpec(),
        customer_location=None,
        candidates=[],
        ranked_results=[],
        rejected_ids=[],
        rank_weights={"sim": 1.0, "quality": 0.7, "distance": 0.5},
        missing_fields=[],
        turn_status="ask",
    )
    graph = get_compiled_graph()

    print("=== First call ===")
    result = await graph.ainvoke(input_msg, config)
    print(f'messages count: {len(result["messages"])}')
    if result["messages"]:
        print(f'last msg: {result["messages"][-1].content}')
    print(f"spec: {result['spec']}")

    print("=== Resume ===")
    resume = {"messages": [HumanMessage(content="minimum budget 100$")]}
    result2 = await graph.ainvoke(resume, config)
    print(f'messages count: {len(result2["messages"])}')
    if result2["messages"]:
        print(f'last msg: {result2["messages"][-1].content}')
    print(f"spec: {result2['spec']}")

if __name__ == "__main__":
    asyncio.run(main())
