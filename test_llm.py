import asyncio
from app.agents.order.nodes import _build_extract_chain
from langchain_core.messages import HumanMessage
import json

async def test():
    chain = _build_extract_chain()
    transcript = "Egyptian Arabic dialect. انا عايز كرتونة لبن"
    result = chain.invoke({"messages": [HumanMessage(content=transcript)]})
    print(result)

if __name__ == "__main__":
    asyncio.run(test())
