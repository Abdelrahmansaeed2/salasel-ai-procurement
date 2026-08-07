# AGENTS.md — Agent & Node Reference

This document specifies every node in the LangGraph pipeline in enough
detail to implement independently. See `architecture.md` for the overall
graph diagram and system context. Each node below states its type, what
state it reads/writes, its exact logic, error handling, and how it's tested
— this is the implementation contract; don't deviate from state field names
without updating `app/agents/state.py` and this file together.

Only **Conversation agent** and **Format results** call an LLM. Every other
node is deterministic Python and must be unit-tested without mocking a model.

---

## Supporting service: product vectorization sync

Not a graph node — the API layer keeps Qdrant in sync with products pushed by
the backend. SQL Server has been removed from this service; the backend (.NET)
is the source of truth and drives Qdrant via `/api/v1/admin/products`.

**File:** `app/services/vector_store.py` (Qdrant client wrapper) +
`app/services/ingestion_service.py` (ingest, single-product update, delete path).

**Trigger:** the backend pushes product create/update via
`POST /api/v1/admin/products` (idempotent batch upsert). Single-product updates
use `PUT /api/v1/admin/products/{id}` (404 on missing; re-embeds only when a
descriptive field — name/sku/category/description/attributes — changes, otherwise
payload-only `set_payload`; `quality_score` is always preserved) and removals use
`DELETE /api/v1/admin/products/{id}`.

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
            "quality_score": supplier.quality_score,  # null until the backend pushes metrics
        },
    )
```

**Quality score updates:** the backend pushes raw review metrics via
`POST /api/v1/admin/quality-metrics`; the AI service computes scores and
issues a payload-only update to every affected product's Qdrant point — it
does not re-embed, since the vector itself doesn't change when a review comes
in.

**Single-product update logic:** `update_product` is update-only (not upsert) —
it 404s on missing products and always preserves `quality_score` from the
existing point.

```python
_TEXT_FIELDS = ("product_name", "sku", "category", "description", "attributes")

async def update_product(product_id: int, product: ProductUpsert) -> dict | None:
    existing = get_product(int(product_id))            # None → 404
    if existing is None:
        return None
    payload = product_payload(product)
    payload["quality_score"] = existing.get("quality_score")   # never reset
    needs_embed = any(existing.get(f) != getattr(product, f) for f in _TEXT_FIELDS)
    if needs_embed:
        vector = await embed(build_product_text(product.product_name, product.sku,
                                                product.category, product.description,
                                                product.attributes))
        vector_upsert(point_id=str(product_id), vector=vector, payload=payload)
    else:
        update_payloads([(str(product_id), payload)])  # payload-only, keeps vector
    return {"re_embedded": needs_embed}
```

Rule of thumb: any change to name/sku/category/description/attributes re-embeds;
price/geo/stock/supplier-only edits are payload-only `set_payload` (no embedding
cost). The endpoint returns `{"status": "ok", "product_id": ..., "re_embedded": ...}`.

**Delete:** `DELETE /api/v1/admin/products/{id}` maps Qdrant
`UpdateStatus.COMPLETED` to an HTTP 200 and anything else (missing point) to 404.

**Testing:** unit test with a fake Qdrant client asserting idempotent
upsert (same `product_id` twice → one point, not two); integration test
verifying a real Qdrant query returns the expected payload after sync.
Also unit-test `update_product` (missing → `None`; descriptive change →
re-embeds and preserves `quality_score`; price-only change → payload-only,
no embed) and `delete_product` status mapping.

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
- product_name: the item the customer is looking for, as they described it
  (e.g. "nitrile gloves", "KN95 masks")
- price_min / price_max: only when the customer states a budget
- required_attributes (key-value pairs the customer mentions, specific to the
  product)

Rules:
- product_name is the required entity field. Do not invent values the customer
  didn't state; set unknown fields to null.
- Do NOT set the category field. The category is derived from our catalog by a
  lookup node, so it must stay null in the LLM's output.
- If the customer's message is ambiguous about which product they want, or they
  ask what options exist, set needs_attribute_lookup=true instead of guessing.
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
  `needs_attribute_lookup=True`, router sends to resolve_product.

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
def route_after_conversation(state: InventoryState) -> Literal["ask_missing_spec", "resolve_product", "retriever"]:
    if not is_spec_complete(state["spec"]):
        return "ask_missing_spec"
    if state["spec"].needs_attribute_lookup or state["spec"].category is None:
        return "resolve_product"
    return "retriever"
```

`spec.is_complete` is computed by a pure function
`is_spec_complete(spec) -> bool` — keep this function separate and unit-tested
on its own, since it's the actual completeness contract. A spec is complete
when `product_name` is non-blank **and** at least one price bound
(`price_min`/`price_max`) is set; both are asked by `ask_missing_spec`, one
question per turn.

**Testing:** exhaustive unit tests over all combinations of
`needs_attribute_lookup` / completeness / category-resolved — this function
fully determines graph behavior and must have 100% branch coverage.

---

## Resolve product

**File:** `app/agents/nodes/resolve_product.py`
**Type:** Deterministic, Redis-cached semantic lookup. No LLM call.

**Reads:** `spec.product_name`
**Writes:** `spec.category` (derived from the catalog), `spec.needs_attribute_lookup`
(reset to `False`), `messages` (catalog matches, or guidance on a miss),
`resolved_candidates` (raw hits incl. product attributes)

The customer supplies a product **name**, not a category. This node embeds the
name and runs a category-less semantic search against Qdrant, then derives the
category from the top-1 hit's payload so downstream exact `category` filters
always use canonical values.

**Logic:**

```python
def resolve_product_node(state: InventoryState) -> dict:
    product_name = state["spec"].product_name
    if product_name is None or not product_name.strip():
        return {
            "messages": [AIMessage(content="What product are you looking for?")],
            "spec": state["spec"].model_copy(update={"needs_attribute_lookup": False}),
        }
    cache_key = f"resolve:{normalize(product_name)}"
    redis_client = Redis.from_url(str(get_settings().redis_url))
    cached = redis_client.get(cache_key)
    if cached is not None:
        resolved = json.loads(cached)
    else:
        query_vec = embed_sync(product_name)
        resolved = vector_search(query_vec, category=None, limit=5)
        redis_client.setex(cache_key, 3600, json.dumps(resolved))
    redis_client.close()
    if not resolved:
        return {
            "messages": [AIMessage(content=f"I couldn't find a product like {product_name!r} in our catalog...")],
            "spec": state["spec"].model_copy(update={"needs_attribute_lookup": False}),
        }
    top = resolved[0]["payload"]
    updated = state["spec"].model_copy(update={"needs_attribute_lookup": False})
    if top.get("category"):
        updated.category = str(top["category"])
    return {"messages": [SystemMessage(content=...)], "spec": updated, "resolved_candidates": resolved}
```

Results are cached in Redis by normalized product name (idempotent — a cache
hit avoids re-embedding and re-searching). A category is only assigned when the
top-1 hit's `similarity_score` meets `resolve_min_similarity`
(`app/core/config.py`) — otherwise the query is treated as a miss so garbage
terms never get misassigned to an unrelated category.

It also writes the raw lookup hits into `resolved_candidates` so the Ask
attributes node has real catalog attribute data to enumerate.

**Routes:** on a hit (category derived) → `ask_attributes`. On a miss →
`END` with a guidance message asking the customer to rephrase (the next user
message restarts from `conversation_agent`).

**Edge cases:** `product_name` is `None`/blank (router bug) → guidance message
and log a warning. No catalog match → guidance message; category stays unset so
`is_spec_complete` stays true but the router re-enters `resolve_product` on the
next turn.

**Testing:** unit test with a fake Redis + fake `vector_search` asserting:
top-1 payload sets `category`, a cache hit avoids `vector_search`, and the
no-hit path returns guidance without setting `category`.

---

## Ask attributes

**File:** `app/agents/nodes/ask_attributes.py`
**Type:** Deterministic, sequential questioning. No LLM call.

**Reads:** `spec.product_name`, `spec.required_attributes`, `resolved_candidates`,
`pending_attributes`, `key_attribute_asked`
**Writes:** `messages` (the question), `key_attribute` (current attribute being
asked), `attribute_options`, `attribute_prompt`, `key_attribute_asked`,
`pending_attributes` (the attributes still left to ask) — or, when there is
nothing left to ask, just `attribute_prompt: null`.

After the product name and category are resolved, this node asks the customer
about **every attribute that varies across the candidate products**, one
attribute per turn (most-varied first), so the retriever can pick the variant
that best matches their preferences. Attributes every candidate shares (e.g.
all gloves are `nitrile`) are skipped as noise.

**Logic:**

```python
def ask_attributes_node(state) -> dict:
    if not state.get("key_attribute_asked"):
        pending = [a for a in plan_attributes(candidates) if a not in answered]
    else:
        pending = [a for a in state.get("pending_attributes", []) if a not in answered]
    if not pending:
        return {"attribute_prompt": None, "pending_attributes": []}
    current, remaining = pending[0], pending[1:]
    options = attribute_values(candidates, current)
    question = f"What {current} would you like? Options: {', '.join(options)}"
    return {"messages": [AIMessage(content=question)],
            "key_attribute": current, "attribute_options": options,
            "attribute_prompt": question, "key_attribute_asked": True,
            "pending_attributes": remaining, "turn_status": "ask"}
```

`plan_attributes` returns the union of attribute keys across candidates that
have more than one distinct value, ordered by distinct-value count descending.
Attributes the customer already supplied (present in `required_attributes`) are
skipped, so a preference stated up front is never re-asked.

**Routes:** on `attribute_prompt` set → `END` (pauses; the customer's answer is
extracted on the next turn by `conversation_agent`, guided by `key_attribute`).
On `attribute_prompt` null → `retriever` directly (sequence finished or nothing
to ask). The router re-enters `ask_attributes` while `pending_attributes` is
non-empty.

The customer's answers flow back through `conversation_agent`, which is prompted
to store them in `required_attributes`; `retriever` then applies each committed
answer as a hard filter (`attributes.<key>` match in Qdrant). Vague answers
("any", "don't care") and values not present in the catalog are **not** applied
as filters, so they never empty the results.

**Testing:** unit test `plan_attributes` ordering/skipping, one-at-a-time
sequencing, skipping already-answered attributes, and sequence completion with
empty `pending_attributes`.

---

## Ask missing spec

**File:** `app/agents/nodes/ask_missing_spec.py`
**Type:** Deterministic/templated. Not a full LLM call — a constrained
template or, at most, a cheap-model paraphrase of a template.

**Reads:** `spec`
**Writes:** `messages` (appends the follow-up question), `missing_fields`

**Logic:**

```python
def ask_missing_spec_node(state: InventoryState) -> dict:
    spec = ProductSpec.model_validate(state["spec"])
    missing = missing_fields(spec)
    if not missing:
        return {"missing_fields": []}
    question = FOLLOWUP_TEMPLATES[missing[0]]  # ask one field at a time, not all at once
    return {"messages": [AIMessage(content=question)], "missing_fields": missing}
```

`missing_fields(spec)` (in `state.py`) drives both this node and
`is_spec_complete`: it returns the `REQUIRED_FIELDS` (`product_name`) the
customer hasn't supplied, plus a synthetic `"price"` entry when neither
`price_min` nor `price_max` is set. Templates ask for the product name first,
then the budget — **one question per turn**.

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
directly.
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
- **Idempotency:** deterministic nodes (router, resolve_product, ask_attributes,
  ask_missing_spec, retriever, rerank) must produce the same output for the same
  input state — required for reliable unit testing and for safe retries on
  transient DB/Redis errors.
- **Timeouts:** every LLM call and DB call in every node must have an
  explicit timeout configured via `app/core/config.py`; no unbounded waits.
- **Logging:** every node logs its entry/exit with `session_id` and a
  summary of what it read/wrote (not full state, to avoid log bloat) —
  needed to reconstruct why a particular ranking or routing decision
  happened after the fact.
