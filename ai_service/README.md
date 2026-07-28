# Salasel AI Service

FastAPI service for the AI procurement supplier-matching pipeline.

**Completed sprints:**

- **Sprint 1** — Foundation scaffold: API bootstrapping, SQL Server/Redis connectivity, Alembic migrations, Docker Compose, seed data, health checks.
- **Sprint 2** — LangGraph multi-agent conversation pipeline: Redis-backed checkpointer, LLM-powered spec extraction, routing, missing-field elicitation, `POST /chat` endpoint.

## Architecture

The system uses a LangGraph `StateGraph` with the following flow:

```
conversation_agent → router →
  ├─ needs_attribute_lookup  → rag_lookup (stub) → conversation_agent
  ├─ spec incomplete         → ask_missing_spec  → conversation_agent
  └─ spec complete           → retriever (stub)   → END
```

- **Conversation agent** — LLM node (AWS Bedrock Claude Sonnet) with structured output to `ProductSpec`. Merges extracted fields into state.
- **Router** — Deterministic conditional edge: picks one branch per turn (RAG lookup, ask missing spec, or retriever). No LLM call.
- **Ask missing spec** — Templated follow-up for one missing field at a time (category, price_min, price_max).
- **RAG lookup / Retriever** — Stubs for Sprints 3 and 4.
- **Checkpointer** — Redis-backed via `RedisSaver`. Sessions survive app restarts.
- **No LLM calls** in router, ask_missing_spec, rag_lookup, or retriever — only conversation_agent invokes the model.

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
| `REDIS_URL` | Redis connection string | `redis://redis:6379/0` |
| `LLM_MODEL` | Anthropic model name | `claude-sonnet-4-20250514` |
| `LLM_ANTHROPIC_API_KEY` | Anthropic API key | *(empty)* |
| `LLM_TEMPERATURE` | Model temperature | `0.0` |

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
continue a session.

```powershell
Invoke-RestMethod http://localhost:8000/api/v1/chat `
  -Method POST `
  -Body '{"session_id": "test-1", "message": "I need office supplies"}'
```

Request:
```json
{"session_id": "string", "message": "string"}
```

Response:
```json
{
  "response": "What category of product are you looking for?",
  "spec": {"category": null, "price_min": null, "price_max": null, ...},
  "turn_status": "ask",
  "missing_fields": ["category", "price_min", "price_max"]
}
```

Sessions are persisted in Redis — an app restart mid-conversation resumes
correctly.

## Docker Setup

Start SQL Server, Redis, and the app:

```powershell
docker compose -f infra/docker/docker-compose.yml up --build
```

Migrations are applied automatically on container start via the entrypoint
script. No manual `alembic upgrade head` needed.

Optional seed data for local testing:

```powershell
docker compose -f infra/docker/docker-compose.yml exec -T sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "YourStrong!Passw0rd" -C -i /work/seed.sql
```

The Compose file mounts `infra/docker/seed.sql` into the SQL Server init
container. The seed file is intentionally test-only and should be run after
migrations.

## Tests

```powershell
pytest
```

19 tests across 5 test files:

| File | Tests | Scope |
|---|---|---|
| `test_config.py` | 1 | Settings defaults |
| `test_health.py` | 2 | Health endpoint (overridden deps, no live DB/Redis) |
| `test_state.py` | 7 | `merge_spec`, `is_spec_complete` |
| `test_router.py` | 5 | All 3 routing branches (100% coverage) |
| `test_ask_missing_spec.py` | 4 | Template selection per missing field |

Default tests use dependency overrides, so they do not require live SQL
Server, Redis, or an LLM connection.
