# AGENTS.md — Agent & Node Reference

This document specifies every node in the LangGraph pipeline in enough
detail to implement independently. See `architecture.md` for the overall
graph diagram and system context. Each node below states its type, what
state it reads/writes, its exact logic, error handling, and how it's tested
— this is the implementation contract; don't deviate from state field names
without updating `app/agents/state.py` and this file together.

Only **Conversation agent** and **Format results** call an LLM. Every other
node is deterministic Python and must be unit-tested without mocking a
model.

---

## Supporting service: product vectorization sync

Not a graph node — a background task that keeps Qdrant in sync with SQL
Server, and a hard dependency of the **Retriever agent** below.

**File:** `app/services/vector_store.py` (Qdrant client wrapper) +
background task triggered from the product create/update path.

**Trigger:** on product create/update in SQL Server (the source of truth).

**Logic:**

```python
async def sync_product_to_vector_store(product: Product, supplier: Supplier):
    vector = await embedding_service.embed(product.to_embedding_text())
    await vector_store.upsert(
        id=product.id,  # idempotent — re-sync overwrites, never duplicates
        vector=vector,
        payload={
            "product_id": product.id,
            "supplier_id": supplier.id,
            "category": product.category,
            "price": product.price,
            "geo": {"lat": supplier.lat, "lon": supplier.lon},
            "quality_score": supplier.quality_score,  # null until Sprint 5's batch job populates it
        },
    )
```

**Quality score updates:** the nightly quality-score batch job
(`app/services/quality_score_job.py`) issues a payload-only update to every
affected product's Qdrant point — it does not re-embed, since the vector
itself doesn't change when a review comes in.

**Testing:** unit test with a fake Qdrant client asserting idempotent
upsert (same `product_id` twice → one point, not two); integration test
verifying a real Qdrant query returns the expected payload after sync.

---

## Conversation agent

**File:** `app/agents/nodes/conversation.py`
**Type:** LLM, structured output
**Model:** primary model (e.g. GPT-4o / Claude Sonnet) — this is the one
node where reasoning quality matters most; don't downgrade to a cheap model
here.

**Reads:** `messages`, `spec` (current partial state)
**Writes:** `spec` (merged, not overwritten)

**System prompt (template):**

```
You are a product-discovery assistant for an inventory platform. Your job
is to extract structured product requirements from the customer's messages
and output them as a ProductSpec JSON object.

Extract or update these fields when the customer provides them:
- category
- price_min / price_max
- required_attributes (key-value pairs specific to the category)

Rules:
- Do not invent values the customer didn't state. Set unknown fields to null.
- If the customer's message is ambiguous about which attributes apply to
  their category, set needs_attribute_lookup=true instead of guessing.
- Do not decide whether the spec is "complete" — that is handled elsewhere.
- Always output a valid ProductSpec JSON object. Never respond conversationally.
```

**Logic:**

```python
def conversation_node(state: InventoryState) -> dict:
    llm = get_llm(role="conversation").with_structured_output(ProductSpec, method="json_mode")
    prompt = ChatPromptTemplate.from_messages([
        ("system", CONVERSATION_SYSTEM_PROMPT),
        MessagesPlaceholder(variable_name="messages"),
    ])
    chain = prompt | llm
    result = ProductSpec.model_validate(chain.invoke({"messages": state["messages"]}))
    merged = merge_spec(state["spec"], result)  # latest non-null value wins per field
    return {"spec": merged}
```

**Edge cases:**

- Contradictory info across turns (e.g. "under $500" then "$800 is fine") →
  `merge_spec` takes the most recent non-null value per field, never
  concatenates or averages.
- Customer asks a question about available options → sets
  `needs_attribute_lookup=True`, router sends to RAG lookup.

**Testing:** integration-level only (requires LLM); assert against fixed
input/output pairs with a recorded/cassette-based LLM response to avoid
flaky live-model tests in CI.

---

## Router

**File:** `app/agents/nodes/router.py`
**Type:** Deterministic conditional edge — no LLM call.

**Reads:** `spec`
**Writes:** nothing — this is a routing function, not a state-mutating node.

**Logic:**

```python
def route_after_conversation(state: InventoryState) -> Literal["rag_lookup", "ask_missing_spec", "retriever"]:
    if state["spec"].needs_attribute_lookup:
        return "rag_lookup"
    if not state["spec"].is_complete:
        return "ask_missing_spec"
    return "retriever"
```

`spec.is_complete` is computed by a pure function
`is_spec_complete(spec) -> bool` checking all `REQUIRED_FIELDS` are
non-null — keep this function separate and unit-tested on its own, since
it's the actual completeness contract.

**Testing:** exhaustive unit tests over all combinations of
`needs_attribute_lookup` / completeness — this function fully determines
graph behavior and must have 100% branch coverage.

---

## RAG lookup

**File:** `app/agents/nodes/rag_lookup.py`
**Type:** Async, Redis-cached.

**Reads:** `spec.category`
**Writes:** `messages` (appends a system message with available attribute
values), `spec.needs_attribute_lookup` (reset to `False`)

**Logic:**

```python
async def rag_lookup_node(state: InventoryState) -> dict:
    category = state["spec"].category
    if category is None:
        return {
            "messages": [SystemMessage(content="I need to know what category you're looking for.")],
            "spec": state["spec"].model_copy(update={"needs_attribute_lookup": False}),
        }
    cache_key = f"attrs:{category}"
    redis_client = Redis.from_url(str(get_settings().redis_url))
    cached = redis_client.get(cache_key)
    if cached is not None:
        attrs = json.loads(cached)
    else:
        async with get_sessionmaker()() as session:
            repo = ProductRepository(session)
            attrs = await repo.get_distinct_attributes(category)
        redis_client.setex(cache_key, 3600, json.dumps(attrs))
    redis_client.close()
    attr_text = "\n".join(f"- {a}" for a in attrs)
    return {
        "messages": [SystemMessage(content=f"Available products in {category}:\n{attr_text}")],
        "spec": state["spec"].model_copy(update={"needs_attribute_lookup": False}),
    }
```

**Always routes to:** `conversation_agent` — never talks to the customer
directly, only enriches context for the next conversation turn.

**Edge cases:** `category` is `None` (shouldn't happen if router logic is
correct, but guard it) → return without a lookup and log a warning, since
this indicates a router/state bug worth catching in tests, not production.

**Testing:** unit test with a fake repository + fake Redis; assert cache
hit avoids the repository call on the second invocation.

---

## Ask missing spec

**File:** `app/agents/nodes/ask_missing_spec.py`
**Type:** Deterministic/templated. Not a full LLM call — a constrained
template or, at most, a cheap-model paraphrase of a template.

**Reads:** `spec`
**Writes:** `messages` (appends the follow-up question), `missing_fields`

**Logic:**

```python
def ask_missing_spec_node(state: InventoryState) -> InventoryState:
    missing = [f for f in REQUIRED_FIELDS if getattr(state["spec"], f) is None]
    question = FOLLOWUP_TEMPLATES[missing[0]]  # ask one field at a time, not all at once
    return {"messages": [AIMessage(content=question)], "missing_fields": missing}
```

**Design note:** ask for one missing field at a time rather than dumping
the whole list — this keeps conversation turns natural and avoids
overwhelming the customer with a checklist.

**Always routes to:** `END` (graph pauses, waits for the next user message
on the same `thread_id` to resume from the entry point).

**Testing:** unit test template selection against every possible missing-field combination.

---

## Retriever agent

**File:** `app/agents/nodes/retriever.py`
**Type:** Deterministic, multi-stage pipeline. No LLM call. Queries Qdrant
directly — does not touch SQL Server in the request path.
**Status:** **Stub until Sprint 4.** Currently returns a placeholder message
and sets `turn_status: "done"`. Full implementation requires Sprint 3's
embedding service, vector store, and Qdrant seeding.

**Reads:** `spec`, `customer_location`, `rejected_ids`, `rank_weights`
**Writes:** `ranked_results`, or routes back with a clarifying `messages`
entry if blocked.

**Stage 1 — embed query + Qdrant vector/payload search:**

```python
query_vec = await embedding_service.embed(spec.to_query_text())

candidates = await vector_store.search(
    vector=query_vec,
    filter={
        "category": spec.category,
        "price": {"gte": spec.price_min, "lte": spec.price_max},
        "geo_radius": {"center": customer_location, "radius_km": DEFAULT_RADIUS_KM},
        "quality_score": {"gte": DEFAULT_QUALITY_THRESHOLD},
        "product_id": {"must_not": state["rejected_ids"]},
    },
    limit=20,  # over-fetch so the blended re-score in stage 3 has room to reorder
)
```

`vector_store.search` wraps Qdrant's query API — vector similarity and
payload filtering happen in a single call, not as two separate steps.

**Stage 2 — zero-result relaxation** (one retry, in this priority order):

1. Widen radius (e.g. ×3)
2. Widen price band (e.g. ±20%)
3. Lower quality threshold (e.g. by one tier)

Re-issue the same Qdrant query with relaxed filter values. If still zero
after relaxation, route to `conversation_agent` with a message explaining
what was relaxed and that nothing was found — never return an empty result
silently.

**Stage 3 — blend and rank:**

```python
w = state["rank_weights"]
ranked = sorted(candidates, key=lambda c: (
    w["sim"] * c.similarity_score +          # returned directly by Qdrant
    w["quality"] * c.payload["quality_score"] +
    w["distance"] * (1 - normalize(c.payload["distance_km"], max_=DEFAULT_RADIUS_KM))
), reverse=True)[:5]
```

Blending stays application-side because `rank_weights` change dynamically
across rerank cycles (Sprint 5) — Qdrant's own similarity ranking is only
one input to the final score, not the final score itself.

**Blocking-field check:** if `customer_location` is `None`, skip the Qdrant
query entirely and route to `conversation_agent` asking for location —
don't issue a geo-radius filter with a null center point.

**Testing:**

- Unit test `ranking_service`'s blending function against a fixed candidate
  list and hand-computed expected order — no Qdrant dependency needed for
  this test.
- Integration test against a seeded Qdrant collection verifying: filter
  correctness (price/radius/quality boundaries), stage 2 relaxation
  triggers on an intentionally over-constrained spec, and that
  `rejected_ids` passed as a `must_not` filter are verifiably absent from
  results (don't only check this in Python post-filtering — assert it was
  pushed into the Qdrant query itself).

---

## Format results

**File:** `app/agents/nodes/format_results.py`
**Type:** LLM, cheap/small model (e.g. GPT-4o-mini) — this is templating
with light natural-language polish, not reasoning; don't use the primary
model here.

**Reads:** `ranked_results`
**Writes:** `messages` (customer-facing explanation), `turn_status = "confirm"`

**System prompt (template):**

```
You are given 5 ranked product/supplier matches as structured data. Write
one short line per result explaining why it matches (price, quality,
distance) in plain language. Do not alter, reorder, or invent values — use
exactly the numbers provided.
```

**Logic:**

```python
def format_results_node(state: InventoryState) -> InventoryState:
    llm = get_llm(role="formatting")
    text = llm.invoke([
        SystemMessage(content=FORMAT_RESULTS_SYSTEM_PROMPT),
        HumanMessage(content=state["ranked_results"].model_dump_json()),
    ])
    return {"messages": [AIMessage(content=text.content)], "turn_status": "confirm"}
```

**Hard rule:** this node must never recompute or adjust `similarity_score`,
`quality_score`, or `distance_km` — it only explains. Enforce this with a
test that diffs `ranked_results` before/after the node runs.

**Testing:** snapshot test against a fixed `ranked_results` fixture with a
cassette-recorded LLM response; assert the underlying scores are unchanged.

---

## Review gate

**File:** `app/agents/nodes/review.py` (or inline in `graph.py`)
**Type:** `interrupt()` — not a compute node. Pauses graph execution.

**Reads:** nothing new (surfaces `ranked_results` + formatted message to
the caller)
**Writes:** nothing until resumed

**Logic:**

```python
def review_gate(state: InventoryState) -> Literal["done", "rerank"]:
    response = interrupt({"results": state["ranked_results"]})
    return "rerank" if response["action"] == "reject" else "done"
```

**Contract:** the `/chat` API layer must expose a way for the client to
resume an interrupted graph run by passing the confirm/reject decision back
in with the same `thread_id` — this is a LangGraph `Command(resume=...)`
call, not a fresh `invoke`.

**Testing:** integration test only — start a run, assert it's interrupted,
resume with reject, assert it reaches `rerank`; resume with confirm,
assert it reaches end.

---

## Rerank

**File:** `app/agents/nodes/rerank.py`
**Type:** Deterministic. No LLM call.

**Reads:** `ranked_results`, `rejected_ids`, `rank_weights`, latest customer
message (rejection reason, if given)
**Writes:** `rejected_ids` (extended), `rank_weights` (adjusted)

**Logic:**

```python
def rerank_node(state: InventoryState) -> InventoryState:
    rejected = state["rejected_ids"] + [c.product_id for c in state["ranked_results"]]
    weights = adjust_weights(state["rank_weights"], state["messages"][-1].content)
    return {"rejected_ids": rejected, "rank_weights": weights}
```

`adjust_weights` is a simple keyword-to-weight-delta mapping for v1 (e.g.
"expensive" → increase implicit price sensitivity, "too far" → increase
`distance` weight) — deterministic and unit-testable, not an LLM call.
Routes back to `retriever_agent`.

**Testing:** unit test `adjust_weights` against a table of rejection-reason
strings → expected weight deltas. Unit test that `rejected_ids` never loses
previously accumulated entries across multiple reject cycles.

---

## Cross-cutting conventions

- **State mutation:** every node returns a partial dict of only the fields
  it changes — never mutate `state` in place, LangGraph merges the return
  value.
- **Idempotency:** deterministic nodes (router, rag_lookup, ask_missing_spec,
  retriever, rerank) must produce the same output for the same input state
  — required for reliable unit testing and for safe retries on transient
  DB/Redis errors.
- **Timeouts:** every LLM call and DB call in every node must have an
  explicit timeout configured via `app/core/config.py`; no unbounded waits.
- **Logging:** every node logs its entry/exit with `session_id` and a
  summary of what it read/wrote (not full state, to avoid log bloat) —
  needed to reconstruct why a particular ranking or routing decision
  happened after the fact.
