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
- **Voice → order drafts** — a dedicated LangGraph pipeline turns a spoken
  request into a structured order schema (products → RAG-enhanced matching →
  deterministic order rendering), aligned with the backend order DTOs.
- **Runs in Docker** — SQL Server + Redis + Qdrant with automatic migrations
  and test-only seed data on startup.

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

Supporting services keep the vector store in sync with the catalog:
- **Product sync** (`app/services/product_sync_service.py`) — embeds products
  and upserts them into Qdrant on create/update (dev/test path).
- **Quality-score job** (`app/services/quality_score_job.py`) — pushes
  payload-only quality-score updates to Qdrant nightly (and once at startup).

### Data flow — SQL-free in production

The AI service never reads SQL Server in the request path. In production the
backend (.NET) is the source of truth and drives Qdrant:

- **Ingestion** — the backend pushes product data via
  `POST /api/v1/admin/products`; the AI service embeds it (name, SKU,
  category, description, attributes) and stores the payload in Qdrant,
  idempotent by `product_id`.
- **Quality** — the backend pushes raw review metrics via
  `POST /api/v1/admin/quality-metrics`; the AI service computes quality
  scores and applies payload-only updates (no re-embed).
- **Retrieval & RAG** — the retriever and RAG lookup read only Qdrant
  payloads (+ Redis cache); no SQL.

SQL Server is used only when `STARTUP_SYNC_ENABLED=true` (default for local
dev/test, which seeds Qdrant from the SQL schema on startup).

## Domain Ownership

The production catalog and supplier domain model lives in
`../backend-dotnet/Salasel.Domain`. The SQLAlchemy models in this service are
AI-service test scaffolding for local development and integration tests. Their
table names intentionally mirror the current .NET entities, but they are not
the source of truth.

## Configuration

Copy `.env.example` to `.env` and set the required values:

| Variable | Description | Default |
|---|---|---|
| `DATABASE_URL` | SQL Server async connection string | `mssql+aioodbc://...` |
| `DB_POOL_SIZE` | Async pool size | `5` |
| `DB_MAX_OVERFLOW` | Max pool overflow | `10` |
| `DB_COMMAND_TIMEOUT_SECONDS` | DB command timeout | `10` |
| `REDIS_URL` | Redis connection string (checkpointer + cache) | `redis://localhost:6379/0` |
| `HEALTH_TIMEOUT_SECONDS` | Health-check timeout | `3` |
| `STARTUP_SYNC_ENABLED` | Seed Qdrant from SQL Server at startup (dev/test) | `true` |
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
Invoke-RestMethod http://localhost:8000/api/v1/health
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
Invoke-RestMethod http://localhost:8000/api/v1/chat `
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
curl.exe -X POST http://localhost:8000/api/v1/voice/transcribe `
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
Same session semantics as `/chat` — reuse `session_id` to continue, and pass
`customer_location` (`"lat,lon"`) to enable geo-radius retrieval.

```powershell
curl.exe -X POST http://localhost:8000/api/v1/voice/chat `
  -F "audio=@recording.m4a" `
  -F "session_id=voice-1" `
  -F "customer_location=30.0444,31.2357"
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
curl.exe -X POST http://localhost:8000/api/v1/voice/order `
  -F "audio=@order.wav" `
  -F 'request={"merchantId": 42, "location": {"lat": 30.04, "lon": 31.24}}'
```

The `request` form field is a JSON-encoded `OrderRequest` (`merchantId`, plus an
optional nested `location {lat, lon}` for near-match ranking) so the backend
caller can post camelCase fields alongside the audio.

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

### POST /api/v1/admin/sync-products

Re-run the product → Qdrant sync on demand (dev/test; uses SQL Server).

```powershell
Invoke-RestMethod http://localhost:8000/api/v1/admin/sync-products -Method POST
```

Response:
```json
{"status": "ok", "message": "Products synced to vector store"}
```

### POST /api/v1/admin/products

Production ingestion: the backend pushes a batch of products; the AI service
embeds them (name, SKU, category, description, attributes) and upserts them
into Qdrant, idempotent by `product_id`. `quality_score` is set to `null` —
populate it via `/api/v1/admin/quality-metrics`.

```bash
curl -X POST http://localhost:8000/api/v1/admin/products \
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
re-embed). Replaces the nightly SQL job in production.

```bash
curl -X POST http://localhost:8000/api/v1/admin/quality-metrics \
  -H "Content-Type: application/json" \
  -d '{"metrics": [{"supplier_id": 1, "review_count": 50, "average_rating": 4.5, "on_time_delivery_rate": 0.95, "defect_rate": 0.02}]}'
```

Response:
```json
{"status": "ok", "updated_suppliers": 1}
```

## Docker Setup

Start SQL Server, Redis, Qdrant, and the app:

```powershell
docker compose -f infra/docker/docker-compose.yml up --build
```

On container start the entrypoint applies Alembic migrations
(`alembic upgrade head`) and runs the test seed data (`seed.sql`, 14
suppliers / 34 catalog items / 14 quality scores) with `sqlcmd -b` so any SQL
error fails startup. No manual migration or seed step is required.

The `app/` directory is volume-mounted with uvicorn `--reload`, so Python
changes hot-reload without a rebuild — but adding a dependency to
`pyproject.toml` requires rebuilding the image (`up --build`).

## Tests

```powershell
pytest
```

67 tests across 16 test files. Unit/API tests use dependency overrides and do
not require live SQL Server, Redis, Qdrant, or an LLM connection. Integration
tests are gated behind `RUN_INTEGRATION=true`.

| File | Tests | Scope |
|---|---|---|
| `test_config.py` | 1 | Settings defaults |
| `test_health.py` | 2 | Health endpoint (overridden deps) |
| `test_voice.py` | 8 | Voice endpoints (stubbed STT + graph) |
| `test_state.py` | 7 | `merge_spec`, `is_spec_complete` |
| `test_router.py` | 5 | All 3 routing branches (100% coverage) |
| `test_retriever.py` | 5 | Retriever location gate + ranked results |
| `test_ask_missing_spec.py` | 4 | Template selection per missing field |
| `test_rag_lookup.py` | 3 | Redis-cached attribute lookup |
| `test_format_results.py` | 3 | Formatting node + unchanged scores |
| `test_rerank.py` | 6 | Weight adjustment + rejected-id accumulation |
| `test_ranking_service.py` | 5 | Blend/rank ordering |
| `test_stt_service.py` | 8 | STT client + validation |
| `test_embedding_service.py` | 2 | Embedding service |
| `test_vector_store.py` | 3 | Qdrant wrapper |
| `test_quality_score_job.py` | 3 | Quality-score payload updates |
| `test_product_repository.py` | 2 | Product repository |
