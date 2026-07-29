# Sprint plan: multi-agent inventory system build

Each sprint below is self-contained enough to paste directly into an agentic
coding tool as its own prompt. Later sprints assume earlier ones are merged
— reference the full architecture doc (`inventory_multiagent_build_prompt.md`)
for the complete graph/state spec; each sprint prompt below only restates
what's new for that phase.

Stack for every sprint: Python 3.12, FastAPI (async), LangChain, LangGraph,
SQLAlchemy 2.0 async targeting SQL Server, Redis, Qdrant (vector store),
Alembic, pytest.

> **Revision note:** Sprint 3 and Sprint 4 below were revised to use a
> dedicated vector database (Qdrant) for product vectors and similarity
> search, replacing the earlier plan of storing embeddings alongside the
> SQL Server row and computing similarity in application memory. SQL Server
> remains the source of truth for product/supplier data; Qdrant holds a
> synced, vectorized copy used only for retrieval.

---

## Sprint 1 — Foundation & scaffolding

**Goal:** A running, empty-but-correct skeleton. No agent logic yet.

**Depends on:** nothing.

**Build:**

- Full folder structure (see architecture doc) with `pyproject.toml`,
  `.env.example`, `app/core/config.py` (pydantic Settings).
- `app/db/session.py` — async SQLAlchemy engine/session factory against SQL
  Server, with explicit `pool_size`/`max_overflow`.
- `app/db/models.py` — `Product`, `Supplier`, `SupplierQualityScore` tables.
  Supplier includes a `geography` column with a spatial index.
- Alembic wired up, initial migration generated and applied.
- `infra/docker/docker-compose.yml` — app + SQL Server + Redis + Qdrant,
  with a seed script inserting sample products/suppliers.
- `app/api/v1/health.py` — `GET /health` checking DB and Redis connectivity.
- `app/main.py` wires the FastAPI app, config, and router.

**Acceptance criteria:**

- `docker compose up` brings up all services (app, SQL Server, Redis, Qdrant).
- `GET /health` returns 200 with DB and Redis both reachable.
- Alembic migration applies cleanly against a fresh SQL Server instance.

**Out of scope:** any LangGraph code, any agent, any endpoint beyond health.

---

## Sprint 2 — Graph skeleton, conversation agent, router

**Goal:** A customer can send a message and the system elicits a complete
`ProductSpec` through multi-turn conversation. No retrieval yet.

**Depends on:** Sprint 1.

**Build:**

- `app/agents/state.py` — `ProductSpec`, `Candidate`, `InventoryState` (full
  schema from the architecture doc, even though `Candidate`/`ranked_results`
  aren't used until Sprint 4 — define them now so the schema is stable).
- `app/agents/checkpointer.py` — Redis or Postgres-backed LangGraph
  checkpointer factory. `MemorySaver` is not acceptable even for this sprint.
- `app/agents/nodes/conversation.py` — LLM node with structured output
  merging into `spec`, never self-deciding completeness.
- `app/agents/nodes/router.py` — pure Python conditional edge routing to
  `rag_lookup`, `ask_missing_spec`, or `retriever`. The `rag_lookup` and
  `retriever` nodes are stubs until Sprints 3 and 4.
- `app/agents/nodes/ask_missing_spec.py` — templated follow-up question
  generation, routes to `END` (graph pauses, waits for next user message).
- `app/agents/graph.py` — compiles the StateGraph with the checkpointer.
- `app/api/v1/chat.py` — `POST /chat` accepting `{session_id, message}`,
  invoking the graph with `thread_id=session_id`.

**Acceptance criteria:**

- A multi-turn conversation via `POST /chat` (same `session_id`) correctly
  accumulates spec fields across turns and asks for whatever's missing.
- Killing and restarting the app mid-conversation and continuing with the
  same `session_id` resumes correctly (proves the checkpointer works).
- Unit tests for `router` and `ask_missing_spec` with no LLM calls involved.

**Out of scope:** RAG lookup, retrieval, ranking, review/rerank.

---

## Sprint 3 — RAG lookup & product vectorization (Qdrant)

**Goal:** The conversation agent can ground clarifying questions in actual
catalog data, and every product is vectorized into a dedicated vector store
ready for similarity search in Sprint 4.

**Depends on:** Sprint 2.

**Build:**

- `app/repositories/product_repository.py`,
  `app/repositories/supplier_repository.py` — async repository layer over
  SQLAlchemy (SQL Server remains the source of truth for all product/
  supplier data).
- `app/agents/nodes/rag_lookup.py` — queries distinct attribute values for
  `spec.category` directly from SQL Server, Redis-cached with an explicit
  TTL, returns to `conversation_agent`. **Unaffected by the vector DB
  change** — this node reads structured attribute metadata, not vectors.
- Wire the router's `needs_attribute_lookup` branch (stubbed in Sprint 2)
  to actually call this node.
- `app/services/embedding_service.py` — embedding generation wrapper, used
  both for product vectorization (this sprint) and for the customer's live
  query text (Sprint 4).
- `app/services/vector_store.py` — Qdrant client wrapper: collection
  creation, upsert, and query methods. Collection schema:
  - vector: product embedding
  - payload: `product_id`, `supplier_id`, `category`, `price`,
    `geo` (supplier lat/long as a Qdrant geo point), `quality_score`
    (defaulted/null until Sprint 5's batch job starts populating it)
- Background task (FastAPI `BackgroundTasks` or a queue) triggered on
  product create/update in SQL Server: generates the embedding and
  **upserts it into Qdrant** with the payload above — replaces the earlier
  plan of storing the embedding as a column on the SQL Server row.
- Idempotent upsert keyed by `product_id` so repeated syncs (e.g. a retry)
  don't create duplicate vectors.

**Acceptance criteria:**

- Asking an ambiguous attribute question ("what colors do you have?") for a
  seeded category returns real values from SQL Server seed data, not a
  hallucinated list.
- Cache hit on a repeated identical attribute query (verify via Redis).
- Creating/updating a seeded product results in a corresponding point in
  the Qdrant collection, verified by querying Qdrant directly (not just
  asserting the background task ran).
- Re-running the sync for the same product does not create a duplicate
  Qdrant point.

**Out of scope:** retrieval/ranking against Qdrant (Sprint 4), quality
score population (Sprint 5 — payload field exists but stays null/default
until then), review/rerank.

---

## Sprint 4 — Retriever agent & ranking (Qdrant-backed)

**Goal:** Given a complete spec, return top-5 ranked, real results via
Qdrant vector + payload search.

**Depends on:** Sprint 3.

**Build:**

- `app/agents/nodes/retriever.py` implementing the pipeline:
  1. Embed the customer's spec into a query vector
     (`embedding_service`, same wrapper used for product vectorization).
  2. Query Qdrant with the query vector plus a payload filter: `category`,
     `price` range, geo-radius filter around `customer_location`,
     `quality_score >= threshold`, `product_id NOT IN rejected_ids`.
     Request more than 5 (e.g. top 20) so the blended re-score in step 4
     has room to reorder.
  3. Zero/low-result relaxation: widen the Qdrant filter in priority order
     (radius → price band → quality threshold), one retry; explain what
     was relaxed if still used.
  4. Blend Qdrant's returned similarity score with `quality_score` and
     normalized distance (computed from the payload geo point) using
     `rank_weights`, take top 5. Blending stays application-side since
     `rank_weights` change dynamically across rerank cycles — Qdrant
     doesn't need to know about weight adjustments.
- Missing-blocking-field branch (e.g. no customer location) routes back to
  `conversation_agent` asking for it specifically, same as before — Qdrant's
  geo filter needs this exactly as SQL Server's did.
- Wire the router's `retriever_agent` branch (stubbed since Sprint 2).
- `app/services/ranking_service.py` — the blended scoring function (now
  operating on Qdrant results instead of SQL rows), unit tested
  independently of Qdrant/DB/HTTP layers.

**Acceptance criteria:**

- A complete spec against seeded/vectorized data returns exactly 5 results
  ordered by blended score, verified against a hand-computed expected order
  for a fixed seed dataset.
- A spec with an impossibly tight radius triggers relaxation via the Qdrant
  filter, and the response explains which constraint was widened.
- Missing customer location correctly routes back to a clarifying question
  instead of querying Qdrant with an invalid filter.
- `rejected_ids` passed as a Qdrant `must_not` filter are verifiably absent
  from results (test this explicitly, since it's easy to get an "on the
  Python side" filter wrong and silently not push it into the Qdrant query).

**Out of scope:** quality score batch job populating real `quality_score`
values (Sprint 5 — until then, seed a static placeholder value in Qdrant
payload so this sprint's ranking tests are deterministic), review/rerank
loop.

---

## Sprint 5 — Quality scoring job & review/rerank loop

**Goal:** Quality scores are computed for real, and customers can reject
results to get a different top 5.

**Depends on:** Sprint 4.

**Build:**

- `app/services/quality_score_job.py` — Bayesian/shrinkage-averaged quality
  score computation from historical order/review data, blended with
  on-time-delivery and defect rate.
- `app/worker/quality_score_scheduler.py` — scheduled batch run (cron-style
  or APScheduler), writes to `SupplierQualityScore` in SQL Server, **and**
  updates the `quality_score` payload field on every affected product's
  point in Qdrant (batch payload update, not a full re-vectorization —
  the embedding itself doesn't change). Never runs in the request path.
  This sync is what lets the Sprint 4 retriever filter/sort on fresh
  quality data without a live SQL join per request.
- `app/agents/nodes/format_results.py` — cheap-model LLM node producing a
  short explanation per result; must not alter scores.
- Review gate implemented with LangGraph `interrupt()` — pauses after
  `format_results`, resumes on the next `/chat` call carrying a
  confirm/reject decision.
- `app/agents/nodes/rerank.py` — on reject: appends shown IDs to
  `rejected_ids`, adjusts `rank_weights` based on rejection reason (simple
  keyword-to-weight mapping is acceptable for v1), routes back to
  `retriever_agent`.

**Acceptance criteria:**

- Running the batch job against seeded historical data produces scores that
  visibly penalize low-review-count suppliers vs. the naive average (proves
  the shrinkage math, not just that a number exists).
- A full confirm cycle and a full reject cycle both work through `/chat`;
  the second result set after rejection excludes all previously shown IDs.
- Quality score computation never appears in the request-path latency
  (batch job is a separate process).
- After the batch job runs, a retrieval query against a product whose
  supplier's score changed reflects the new `quality_score` from Qdrant's
  payload — without the retriever ever querying SQL Server directly.

**Out of scope:** load testing, rate limiting, production observability.

---

## Sprint 6 — Scalability & production hardening

**Goal:** The system holds up under thousands of concurrent sessions.

**Depends on:** Sprint 5 (full graph must be complete).

**Build:**

- Per-user token-bucket rate limiting on `/chat` (`app/core/rate_limit.py`),
  returning 429 rather than queuing.
- Timeouts + circuit breaking around every LLM and DB call, configurable via
  `config.py`.
- Structured JSON logging with `session_id`/`request_id` on every line;
  LangSmith tracing toggle via env var.
- Confirm the checkpointer is genuinely externalized: run 2+ app replicas
  behind a simple load balancer and prove a session started on replica A can
  resume on replica B.
- `tests/load/locustfile.py` simulating 1,000 concurrent multi-turn
  sessions.
- `README.md` documenting: how to run locally, graph routing, session model,
  and the load test results (p95/p99 latency, error rate, any bottlenecks
  found and how they were addressed).

**Acceptance criteria:**

- Locust run against 1,000 concurrent simulated sessions completes with
  documented p95/p99 latency and error rate — numbers included in the
  README, not just "it ran."
- Cross-replica session resume test passes.
- No blocking (sync) I/O calls anywhere in the request path (verify via
  code review / a lint rule if feasible).

---

## How to use this with an agentic coding tool

Paste one sprint at a time as its own prompt, in order — don't paste all six
at once. Each sprint's acceptance criteria are meant to be checked (tests
run, endpoint hit, behavior verified) before moving to the next, since
Sprints 2-6 each build directly on the previous graph wiring.
