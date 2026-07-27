# Salasel AI Service

FastAPI service for the AI procurement supplier-matching pipeline.

Sprint 1 is a foundation scaffold only. It provides API bootstrapping,
configuration, SQL Server connectivity, Redis connectivity, Alembic, Docker
assets, seed data, and health checks. LangGraph agents and `/chat` start in
Sprint 2.

## Domain Ownership

The production catalog and supplier domain model lives in
`../backend-dotnet/Salasel.Domain`. The SQLAlchemy models in this service are
AI-service test scaffolding for local development and integration tests. Their
table names intentionally mirror the current .NET entities, but they are not
the source of truth.

## Local Setup

Install dependencies:

```powershell
pip install -e ".[dev]"
```

Run the API:

```powershell
uvicorn app.main:app --reload
```

Health check:

```powershell
Invoke-RestMethod http://localhost:8000/api/v1/health
```

## Docker Setup

Start SQL Server, Redis, and the app:

```powershell
docker compose -f infra/docker/docker-compose.yml up --build
```

Apply migrations from the repo root:

```powershell
alembic upgrade head
```

Optional seed data for local testing:

```powershell
docker compose -f infra/docker/docker-compose.yml exec -T sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "YourStrong!Passw0rd" -C -i /work/seed.sql
```

The Compose file mounts `infra/docker/seed.sql` into the SQL Server init
container. The seed file is intentionally test-only and should be run after
`alembic upgrade head`.

## Tests

```powershell
pytest
```

The default tests use dependency overrides for health checks, so they do not
require live SQL Server or Redis.
