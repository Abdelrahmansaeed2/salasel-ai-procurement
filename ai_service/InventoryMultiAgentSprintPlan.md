# Sprint plan: multi-agent inventory system build

Each sprint below is self-contained enough to paste directly into an agentic
coding tool as its own prompt. Later sprints assume earlier ones are merged
— reference the full architecture doc (`inventory_multiagent_build_prompt.md`)
for the complete graph/state spec; each sprint prompt below only restates
what's new for that phase.

Stack for every sprint: Python 3.12, FastAPI (async), LangChain, LangGraph,
SQLAlchemy 2.0 async targeting SQL Server, Redis, Alembic, pytest.

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
- `infra/docker/docker-compose.yml` — app + SQL Server + Redis, with a seed
  script inserting sample products/suppliers.
- `app/api/v1/health.py` — `GET /health` checking DB and Redis connectivity.
- `app/main.py` wires the FastAPI app, config, and router.

**Acceptance criteria:**

- `docker compose up` brings up all three services.
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
- `app/agents/nodes/router.py` — pure Python conditional edge; for this
  sprint it only has two live branches (`ask_missing_spec`,
  END-if-complete) — the `rag_lookup` and `retriever_agent` branches are
  stubbed as no-ops returning a placeholder message, to be implemented in
  Sprints 3 and 4.
- `app/agents/nodes/ask_missing_spec.py` — templated follow-up question
  generation, returns to `conversation_agent`.
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

## Sprint 3 — RAG lookup & data grounding

**Goal:** The conversation agent can ground clarifying questions in actual
catalog data instead of guessing.

**Depends on:** Sprint 2.

**Build:**

- `app/repositories/product_repository.py`,
  `app/repositories/supplier_repository.py` — async repository layer over
  SQLAlchemy.
- `app/agents/nodes/rag_lookup.py` — queries distinct attribute values for
  `spec.category`, Redis-cached with an explicit TTL, returns to
  `conversation_agent`.
- Wire the router's `needs_attribute_lookup` branch (stubbed in Sprint 2)
  to actually call this node.
- Background task (FastAPI `BackgroundTasks` or a simple queue) that
  precomputes and stores a product's embedding on create/update.
- `app/services/embedding_service.py` — embedding generation wrapper.

**Acceptance criteria:**

- Asking an ambiguous attribute question ("what colors do you have?") for a
  seeded category returns real values from the seed data, not a
  hallucinated list.
- Cache hit on a repeated identical attribute query (verify via Redis, not
  just behaviorally).
- New/updated products get an embedding populated without blocking the
  write request.

**Out of scope:** retrieval/ranking, review/rerank.

---

## Sprint 4 — Retriever agent & ranking

**Goal:** Given a complete spec, return top-5 ranked, real results.

**Depends on:** Sprint 3.

**Build:**

- `app/agents/nodes/retriever.py` implementing the three-stage pipeline:
  1. SQL Server structured filter (category, price range,
     `geography.STDistance()` radius, `quality_score` threshold, excluding
     `rejected_ids` — even though rerank isn't built yet, filter for it now).
  2. Zero-result relaxation (radius → price band → quality threshold, one
     retry, explain what was relaxed if still used).
  3. In-memory cosine similarity re-rank blended with quality/distance via
     `rank_weights` (default weights defined in config).
- Missing-blocking-field branch (e.g. no customer location) routes back to
  `conversation_agent` asking for it specifically.
- Wire the router's `retriever_agent` branch (stubbed since Sprint 2).
- `app/services/ranking_service.py` — the blended scoring function, unit
  tested independently of the DB/HTTP layers.

**Acceptance criteria:**

- A complete spec against seed data returns exactly 5 results ordered by
  blended score, verified against a hand-computed expected order for a
  fixed seed dataset.
- A spec with an impossibly tight radius triggers relaxation, and the
  response explains which constraint was widened.
- Missing customer location correctly routes back to a clarifying question
  instead of erroring.

**Out of scope:** quality score batch job (assume `SupplierQualityScore` is
pre-seeded for now), review/rerank loop.

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
  or APScheduler), writes to `SupplierQualityScore`, never runs in the
  request path.
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
