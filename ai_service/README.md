# Salasel AI Service

FastAPI service for the AI procurement supplier-matching pipeline.

## Capabilities

- **Multi-turn agent conversation** — a LangGraph `StateGraph` extracts a
  structured `ProductSpec` from natural language, asks for missing fields one
  at a time, and answers clarifying attribute questions.
- **Vector retrieval** — product/supplier matches are embedded with
  fastembed and searched in Qdrant with vector similarity + payload filters
  (category, price band, geo radius, quality score, rejected ids).
- **Ranking & review loop** — results are blended by similarity/quality/
  distance weights, surfaced to the customer, and re-run with adjusted
  weights when a match is rejected.
- **Voice ordering** — audio uploads are transcribed to text (Groq Whisper)
  and fed through the same agent pipeline.
- **Voice → order drafts** — a dedicated, single-turn 5-node LangGraph
  pipeline (2 LLM calls) turns a spoken request into a structured order schema
  (extract products → RAG-enhanced matching → deterministic order rendering),
  aligned with the backend `OrderExecutionRequestDto`.
- **Runs in Docker** — Redis + Qdrant only; no database. Catalog data arrives
  via the admin ingestion endpoints from the backend.

## Architecture

The system uses a LangGraph `StateGraph` with the following flow:

```
conversation_agent → router →
  ├─ needs_attribute_lookup → rag_lookup → conversation_agent
  ├─ spec incomplete        → ask_missing_spec → END
  └─ spec complete          → retriever → format_results → review_gate →
       ├─ done → END
       └─ rerank → retriever
```

- **Conversation agent** — LLM node (primary model) with structured output to
  `ProductSpec`. Extracts category / price range / attributes and merges them
  into state; latest non-null value per field wins.
- **Router** — deterministic conditional edge: picks one branch per turn
  (RAG lookup, ask missing spec, or retriever). No LLM call.
- **Ask missing spec** — templated follow-up for one missing field at a time
  (category, price_min, price_max).
- **RAG lookup** — Redis-cached list of available attribute values for the
  category, appended as context for the next conversation turn.
- **Retriever** — deterministic multi-stage pipeline. Embeds the spec, runs a
  Qdrant vector + payload search with geo-radius / price / quality filters,
  relaxes the filter once on zero results, then blends and ranks. No LLM call.
- **Format results** — cheap/small LLM that explains each ranked match in one
  line without altering the underlying scores.
- **Review gate** — an `interrupt()` that pauses the graph until the customer
  confirms or rejects the ranked results.
- **Rerank** — deterministic keyword-to-weight adjustment of `rank_weights`
  and accumulation of `rejected_ids`, then re-runs the retriever.
- **Checkpointer** — Redis-backed via `RedisSaver`. Sessions survive app
  restarts and the review gate resumes with the same `thread_id`.
- **LLM usage** — only `conversation_agent` and `format_results` call an LLM;
  every other node is deterministic Python.

### Order pipeline

The `/voice/order` endpoint runs a separate, single-turn 5-node graph
(`app/agents/order/`) with no checkpointer — each request compiles a fresh
graph, so there is no pause/resume. Two of the five nodes call an LLM (the
primary model via the shared `conversation` role); the rest are deterministic
or RAG-based:

```
extract_products → enrich_metadata → resolve_defaults → match_best → generate_order → END
```

- **Extract products** — LLM (primary model, structured `json_mode`). Parses
  the transcript into `OrderLine[]` (`product_name`, `quantity`, `category`,
  `requested_attributes`, price bounds); unknown fields stay null; an empty
  extraction sets an error.
- **Enrich metadata** — per line, embeds the product name and searches Qdrant
  for candidate `ProductMatch` payloads (no LLM).
- **Resolve defaults** — deterministic. Quantity defaults to 1 and absent
  attributes are back-filled from the catalog payload (user value wins).
- **Match best** — embeds name + resolved attributes, re-searches with
  category/price filters, and when a customer location is present blends
  similarity/quality/distance (default weights 1.0/0.7/0.5) to pick the best
  match; computes the line subtotal.
- **Generate order** — deterministic. Assembles the `OrderResponse`
  (`merchant_id`, `total_order_cost`, `splits[]`, `unresolved[]`) mirroring
  the backend's `OrderExecutionRequestDto`. Lines that never matched land in
  `unresolved` — never silently dropped.

### Data flow — SQL-free

The AI service has no database dependency. The backend (.NET) is the source of
truth and drives Qdrant:

- **Ingestion** — the backend pushes product data via
  `POST /api/v1/admin/products`; the AI service embeds it (name, SKU,
  category, description, attributes) and stores the payload in Qdrant,
  idempotent by `product_id`.
- **Quality** — the backend pushes raw review metrics via
  `POST /api/v1/admin/quality-metrics`; the AI service computes quality
  scores and applies payload-only updates (no re-embed).
- **Retrieval & RAG** — the retriever and RAG lookup read only Qdrant
  payloads (+ Redis cache); no SQL.

A freshly-started stack has an empty catalog until the backend pushes data
through the admin endpoints.

## Domain Ownership

The production catalog and supplier domain model lives in
`../backend-dotnet/Salasel.Domain`. The AI service never stores catalog data
itself — Qdrant holds the searchable snapshot pushed via `/api/v1/admin/*`,
and the backend remains the source of truth.

## Configuration

Copy `.env.example` to `.env` and set the required values:

| Variable | Description | Default |
|---|---|---|
| `REDIS_URL` | Redis connection string (checkpointer + cache) | `redis://localhost:6379/0` |
| `HEALTH_TIMEOUT_SECONDS` | Health-check timeout | `3` |
| `LLM_PROVIDER` | LLM provider (`groq` or `anthropic`) | `groq` |
| `LLM_MODEL` | Primary model name | `llama-3.3-70b-versatile` |
| `LLM_GROQ_API_KEY` | Groq API key | *(empty)* |
| `LLM_ANTHROPIC_API_KEY` | Anthropic API key | *(empty)* |
| `LLM_TEMPERATURE` | Primary model temperature | `0.0` |
| `LLM_TIMEOUT` | Primary model timeout (s) | `30` |
| `LLM_MAX_TOKENS` | Max completion tokens for LLM calls | `4096` |
| `LLM_FORMATTING_MODEL` | Format-results model | `llama-3.1-8b-instant` |
| `STT_PROVIDER` | Speech-to-text provider | `groq` |
| `STT_MODEL` | Transcription model | `whisper-large-v3-turbo` |
| `STT_API_KEY` | STT API key (falls back to `LLM_GROQ_API_KEY`) | *(empty)* |
| `STT_TIMEOUT` | Transcription timeout (s) | `60` |
| `STT_LANGUAGE` | Force language (`ar`, `en`); empty = auto-detect | *(empty)* |
| `STT_MAX_AUDIO_BYTES` | Max upload size in bytes | `26214400` (25 MB) |
| `QDRANT_URL` | Qdrant endpoint | `http://localhost:6333` |
| `EMBEDDING_MODEL` | fastembed model | `BAAI/bge-small-en-v1.5` |
| `DEFAULT_RADIUS_KM` | Default geo search radius | `50` |
| `DEFAULT_QUALITY_THRESHOLD` | Min quality score | `0.0` |
| `RANK_WEIGHT_SIMILARITY` | Blend weight: similarity | `1.0` |
| `RANK_WEIGHT_QUALITY` | Blend weight: quality | `0.7` |
| `RANK_WEIGHT_DISTANCE` | Blend weight: distance | `0.5` |

## Local Setup

```powershell
# Install dependencies (including dev extras)
pip install -e ".[dev]"

# Copy and edit environment
cp .env.example .env

# Run the API
uvicorn app.main:app --reload
```

## API Endpoints

All routes are served under the `/api/v1` prefix. The complete, interactive
docs are available at `/docs` (Swagger UI) and `/redoc` while the service
runs; see [docs/API.md](docs/API.md) for the full written reference.

### GET /api/v1/health

Returns service health status (DB + Redis reachability).

```powershell
Invoke-RestMethod http://127.0.0.1:8000/api/v1/health
```

Response:
```json
{"status": "ok", "database": true, "redis": true}
```

### POST /api/v1/chat

Send a message in a multi-turn conversation. Use the same `session_id` to
continue a session. `customer_location` is optional and enables geo-radius
retrieval.

```powershell
Invoke-RestMethod http://127.0.0.1:8000/api/v1/chat `
  -Method POST `
  -Body '{"session_id": "test-1", "message": "I need PPE under 5 dollars", "customer_location": [30.0444, 31.2357]}'
```

Request:
```json
{
  "session_id": "string",
  "message": "string",
  "customer_location": [30.0444, 31.2357]
}
```

Response:
```json
{
  "response": "What is your minimum budget for this product?",
  "spec": {"category": "PPE", "price_min": null, "price_max": null, "required_attributes": {}, "is_complete": false, "needs_attribute_lookup": false},
  "turn_status": "ask",
  "missing_fields": ["price_min", "price_max"],
  "ranked_results": []
}
```

When the spec is complete, `ranked_results` contains up to 5 ranked
product/supplier matches and `turn_status` becomes `confirm`; a follow-up
message confirming or rejecting the results resumes the interrupted review
gate. Sessions are persisted in Redis — an app restart mid-conversation
resumes correctly.

### POST /api/v1/voice/transcribe

Transcribe an audio file to text (multipart `audio` field).

```powershell
curl.exe -X POST http://127.0.0.1:8000/api/v1/voice/transcribe `
  -F "audio=@recording.m4a"
```

Response:
```json
{"text": "I need PPE with a budget between 2 and 5 dollars", "language": "ar"}
```

`language` is the detected ISO-639-1 code (empty when unavailable). Errors:
`413` file too large, `415` unsupported format, `422` no speech detected.

### POST /api/v1/voice/chat

Transcribe an audio file and run it through the agent pipeline in one call.
Same session semantics as `/chat` — reuse `session_id` to continue. The
`request` form field is a JSON-encoded `VoiceChatRequest` with `session_id`
(required) and an optional `customer_location` `[lat, lon]` array enabling
geo-radius retrieval.

```powershell
curl.exe -X POST http://127.0.0.1:8000/api/v1/voice/chat `
  -F "audio=@recording.m4a" `
  -F 'request={"session_id": "voice-1", "customer_location": [30.0444, 31.2357]}'
```

Returns the same `ChatResponse` shape as `/api/v1/chat`.

### POST /api/v1/voice/order

Transcribe an audio recording and generate a draft order schema in one call.
Runs a dedicated 5-node LangGraph pipeline (`app/agents/order/`): extract
requested products (LLM) → enrich with RAG metadata from Qdrant → resolve
defaults (user value wins, else catalog/default) → match each product to its
best vector-store match → assemble the schema deterministically. The output
matches the backend's `OrderExecutionRequestDto` (merchant, splits with
supplier/SKU/quantity/subtotal, totals).

```powershell
curl.exe -X POST "http://127.0.0.1:8000/api/v1/voice/order/42?lat=30.04&lon=31.24" `
  -F "audio=@order.wav"
```

The merchant ID is a path parameter; an optional `lat`/`lon` query pair enables
near-match ranking (both must be provided together). No request body is needed
besides the audio file.

Response:
```json
{
  "merchant_id": 42,
  "total_order_cost": 18.75,
  "splits": [
    {"supplier_id": 10, "sku": "NG-M", "quantity_ordered": 5, "sub_total_cost": 18.75}
  ],
  "unresolved": []
}
```

Products that cannot be matched to the catalog appear in `unresolved` for
review — never silently dropped.

### POST /api/v1/admin/products

Production ingestion: the backend pushes a batch of products; the AI service
embeds them (name, SKU, category, description, attributes) and upserts them
into Qdrant, idempotent by `product_id`. `quality_score` is set to `null` —
populate it via `/api/v1/admin/quality-metrics`.

```bash
curl -X POST http://127.0.0.1:8000/api/v1/admin/products \
  -H "Content-Type: application/json" \
  -d '{"products": [{"product_id": 1, "supplier_id": 1, "product_name": "Nitrile Gloves Medium", "sku": "NG-MED", "category": "PPE", "description": "Disposable exam gloves", "attributes": {"size": "M"}, "price": 3.75, "lat": 30.04, "lon": 31.24, "in_stock": true}]}'
```

Response:
```json
{"status": "ok", "synced": 1}
```

### POST /api/v1/admin/quality-metrics

The backend pushes raw review metrics; the AI service computes quality scores
and applies payload-only updates to every product of each supplier (no
re-embed).

```bash
curl -X POST http://127.0.0.1:8000/api/v1/admin/quality-metrics \
  -H "Content-Type: application/json" \
  -d '{"metrics": [{"supplier_id": 1, "review_count": 50, "average_rating": 4.5, "on_time_delivery_rate": 0.95, "defect_rate": 0.02}]}'
```

Response:
```json
{"status": "ok", "updated_suppliers": 1}
```

## Docker Setup

Start Redis, Qdrant, and the app:

```powershell
docker compose -f infra/docker/docker-compose.yml up --build
```

The service has no database — no migrations or seed step. A freshly-started
stack has an empty catalog until the backend pushes data via
`POST /api/v1/admin/products` (+ `/api/v1/admin/quality-metrics`).

The `app/` directory is volume-mounted with uvicorn `--reload`, so Python
changes hot-reload without a rebuild — but adding a dependency to
`pyproject.toml` requires rebuilding the image (`up --build`).

## Tests

```powershell
pytest
```

96 tests across 20 test files. Unit/API tests use dependency overrides and do
not require live Redis, Qdrant, or an LLM connection. Integration tests are
gated behind `RUN_INTEGRATION=true`.

| File | Tests | Scope |
|---|---|---|
| `test_config.py` | 1 | Settings defaults |
| `test_health.py` | 2 | Health endpoint (overridden deps) |
| `test_voice.py` | 9 | Voice endpoints (stubbed STT + graph) |
| `test_order_api.py` | 6 | `/voice/order` endpoint (path/query parsing + validation) |
| `test_admin.py` | 3 | Admin ingest/quality endpoints |
| `test_state.py` | 7 | `merge_spec`, `is_spec_complete` |
| `test_router.py` | 5 | All 3 routing branches (100% coverage) |
| `test_retriever.py` | 5 | Retriever location gate + ranked results |
| `test_ask_missing_spec.py` | 4 | Template selection per missing field |
| `test_rag_lookup.py` | 4 | Redis-cached attribute lookup |
| `test_format_results.py` | 3 | Formatting node + unchanged scores |
| `test_rerank.py` | 6 | Weight adjustment + rejected-id accumulation |
| `test_ranking_service.py` | 5 | Blend/rank ordering + haversine |
| `test_stt_service.py` | 8 | STT client + validation |
| `test_embedding_service.py` | 2 | Embedding service |
| `test_ingestion_service.py` | 3 | Admin ingestion payload handling |
| `test_vector_store.py` | 8 | Qdrant wrapper (sync + payload updates) |
| `test_quality_score_service.py` | 4 | Score computation |
| `test_order_nodes.py` | 9 | Order pipeline nodes |
| `test_order_service.py` | 2 | Order pipeline orchestration |
