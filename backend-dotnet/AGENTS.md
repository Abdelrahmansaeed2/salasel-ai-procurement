# AGENTS.md — Salasel .NET Backend

Agent & contributor reference for the Salasel core backend. See
`architecture.md` for the system/module design, and the repo root
`README.md` for the product as a whole. This file is the implementation
contract — follow it when adding or changing backend code.

**Stack:** .NET 10, ASP.NET Core Web API, EF Core 10 + SQL Server,
FluentValidation, Serilog + Seq, SignalR, JWT auth.

---

## 1. Solution layout & layering

```
backend-dotnet/
├── Salasel.sln
├── Salasel.Domain/            # Zero dependencies. Entities + enums only.
├── Salasel.Application/       # DTOs, service interfaces, validators, business logic.
├── Salasel.Infrastructure/    # EF DbContext, migrations, repositories, workers, SignalR hub, email, AI stub.
└── Salasel.API/               # Program.cs, controllers, middlewares, configuration only.
```

### Layer rules (non-negotiable)

| Layer | May reference | Must NOT reference |
| ----- | ------------- | ------------------ |
| `Domain` | (nothing — pure CLR) | anything outside itself |
| `Application` | `Domain` | `Infrastructure`, `API`, EF types |
| `Infrastructure` | `Domain`, `Application` (interfaces) | `API` |
| `API` | all others | — |

- All abstractions live in `Salasel.Application/Interfaces/`; implementations
  live in `Salasel.Infrastructure/`. Controllers depend on interfaces only —
  never on concrete repositories/services.
- DTOs go in `Salasel.Application/DTOs/`, one file per feature area
  (e.g. `BiddingDtos.cs`, `InventoryDtos.cs`). Don't scatter single-class files
  unless the type is large enough to justify it.
- New entities must be registered in `SalaselDbContext` **and** covered by a
  new EF Core migration (see §5).

---

## 2. Commands

```powershell
# Build / restore
dotnet restore
dotnet build

# Run locally (SQL Server must be up; see docker-compose at repo root)
dotnet run --project Salasel.API

# EF migrations — project & startup project are ALWAYS required
dotnet ef migrations add <Name> -p Salasel.Infrastructure -s Salasel.API

# Full local dev stack in Docker — sqlserver, seq, redis, qdrant, api, and the AI service (from backend-dotnet/)
docker compose up -d --build
```

The solution currently has **no test project**. If you add tests, put them in a
new `Salasel.Tests/` project referencing `Salasel.Application` /
`Salasel.Infrastructure` and register them in `Salasel.sln`.

---

## 3. Dependency injection

Everything is registered in `Salasel.API/Program.cs` — never use service
locator / static singletons in business code.

- **Repositories:** one `AddScoped` line per interface → concrete class.
  Generic `IRepository<T>` is mapped to `Repository<T>`; specialized
  repositories override it for query-heavy aggregates (see §4).
- **Services:** `AddScoped` for per-request services.
- **Background pipelines** (`BackgroundQueue`, `KnowledgeIndexingQueue`,
  `NotificationService`, `IAIService`): **`AddSingleton`**, with their
  hosted workers registered via `AddHostedService<T>()`.
- **External HTTP clients** (`IAIService`, `IAISyncService`): registered with
  `AddHttpClient<...>` and `BaseAddress` from `AiService:BaseUrl`.
- Validation: `AddFluentValidationAutoValidation()` +
  `AddValidatorsFromAssemblyContaining<RegisterRequestDtoValidator>()` — new
  validators are picked up automatically.

Register new services here, in the matching section (Repositories / Services /
Voice pipeline / Knowledge indexing), keeping the existing grouping.

---

## 4. Controller & service conventions

- Async everywhere: `Task<ActionResult<T>>` / `Task<T>`. No blocking `.Result`
  or `.Wait()`.
- Controllers use attribute routing (`[Route("api/...")]`), return
  `Ok(...)` / `CreatedAtAction` / `NotFound` / `BadRequest` explicitly, and
  **do not contain business logic** — they map HTTP → service calls.
- Request validation lives in `Salasel.Application/Validators/` as
  FluentValidation validators (e.g. `AuthValidators.cs`); controllers don't
  hand-validate.
- Domain errors should surface as HTTP status codes, not raw exceptions. The
  `GlobalExceptionMiddleware` catches unexpected exceptions — don't rely on it
  for control flow.
- New features that map to a controller: add DTOs → interface in
  `Application/Interfaces` → implementation in `Infrastructure/Services` →
  register in `Program.cs` → controller.

### Repositories

- `Salasel.Infrastructure/Repositories/Repository<T>` provides the generic
  CRUD baseline via `IRepository<T>`.
- Specialized repositories (e.g. `MasterOrderRepository`,
  `SupplierProductRepository`) exist for query-heavy aggregates — follow the
  pattern in the nearest sibling (async, `Include`/`ThenInclude` explicit,
  returns DTOs or entities as appropriate).

---

## 5. EF Core / migrations

- **Never hand-edit a migration.** All schema changes come from
  `dotnet ef migrations add <Name> -p Salasel.Infrastructure -s Salasel.API`.
- On startup, `Program.cs` calls `db.Database.Migrate()` inside a try/catch
  and **deliberately keeps the app alive on failure** so nginx and
  `/api/diagnostics` still respond (`Program.cs:187-210`). Do not change this
  to throw.
- CI (`.github/workflows/Deploy.yml`) auto-generates a migration on every push
  to `main` if model changes are detected, committing it back as
  `chore: auto-generate missing EF Core migration [skip ci]`. Keep the model
  buildable so that step succeeds.
- Each migration ships as `<Timestamp>_<Name>.cs` +
  `<Timestamp>_<Name>.Designer.cs`; the snapshot
  `Migrations/SalaselDbContextModelSnapshot.cs` is updated automatically.

---

## 6. Auth & security

- JWT bearer auth configured in `Program.cs` with issuer/audience/key from
  config. Swagger carries a `Bearer` security definition.
- **Token revocation:** `JwtBearerEvents.OnTokenValidated` re-checks the
  user's `TokenVersion` claim against the DB every request
  (`Program.cs:68-89`). Logout / password change bumps `TokenVersion` — any
  code that invalidates sessions must increment that value.
- Never log secrets, JWT keys, passwords, or connection strings. Serilog
  request logging is enabled (`UseSerilogRequestLogging`).

---

## 7. Background pipelines

Two HostedService worker patterns, both queued:

1. **Voice procurement** — `VoiceController` enqueues raw voice requests onto
   `BackgroundQueue`; `VoiceProcessingWorker` uploads the audio to the real
   `ai_service` via `IAIService` (`POST /api/v1/voice/order/{merchantId}`),
   writes `VoiceProcurementLog`, and creates a `MasterOrder` (`Source = Voice`)
   with `SubOrder`s. Progress is pushed over SignalR via `NotificationService`.
2. **Knowledge indexing** — `AdminKnowledgeBaseController` /
   `SupplierKnowledgeController` enqueue indexing jobs onto
   `KnowledgeIndexingQueue`; `KnowledgeIndexingWorker` runs them.

Rules for new workers: singleton queue + hosted worker, enqueue is
non-blocking, worker is idempotent on retry, progress/notifications go through
`INotificationService`.

---

## 8. SignalR

- Hub: `Salasel.Infrastructure/Hubs/NotificationHub.cs`, mapped at
  `/notificationHub` in `Program.cs`.
- JSON is camelCase (`AddJsonProtocol`). Max receive size is raised to 10 MB.
- Push real-time updates (order status, bid events, alerts) through
  `INotificationService`, not by calling the hub directly.

---

## 9. AI service integration points

- The backend calls the external `ai_service` (FastAPI) through two typed HTTP
  clients, both with `BaseAddress` from `AiService:BaseUrl`:
  `IAIService` (voice order: `POST /api/v1/voice/order/{merchantId}`) and
  `IAISyncService` (catalog push: `POST /api/v1/admin/products`). Do not
  inline AI logic into the backend.
- The backend remains the **source of truth** for products/suppliers. It pushes
  products & quality metrics to Qdrant via the `ai_service` admin endpoints (see
  `../ai_service/architecture.md` §4) — don't add a second source of truth.
  Catalog sync runs best-effort on startup (`CatalogSyncWorker`) and on demand
  via `POST /api/v1/admin/ai/sync-catalog`.
- `AiController.cs` / `AiDtos.cs` host the current AI-facing surface; keep DTO
  shapes aligned with `ai_service` schemas.
- **Public proxy forwarding:** `AiController` exposes three anonymous relay
  routes to ai_service, returning its JSON verbatim — `POST /api/v1/ai/chat`,
  `POST /api/v1/ai/order/{merchantId}`, `POST /api/v1/ai/voice/order/{merchantId}`
  (multipart `file` + `lat`/`lon`). Request payloads are serialized snake_case to
  match pydantic (see `ChatRequestPayload`/`OrderRequestPayload` in `AiDtos.cs`).
- Full reference: `docs/ai-service-integration.md` (config, DTOs, voice
  pipeline, catalog sync, testing/troubleshooting).

---

## 10. Middleware & observability

Pipeline order in `Program.cs`:

`GlobalExceptionMiddleware` → `LangfuseMiddleware` → static files →
`SerilogRequestLogging` → CORS → auth → authorization → hubs/controllers.

- `GlobalExceptionMiddleware` normalizes unexpected errors into a consistent
  JSON shape.
- `LangfuseMiddleware` traces requests for LLM/agent observability.
- Logging: Serilog to Console + rolling file (`logs/log-*.txt`) + Seq
  (`Seq:Url`). Every log line should carry enough context
  (request path, `session_id`/`request_id` where relevant) to reconstruct a
  decision.

---

## 11. Configuration

- `appsettings.json` / `appsettings.Development.json` /
  `appsettings.Production.json` for non-secret config.
- Secrets (JWT key, connection strings, SMTP) come from environment variables
  injected by `docker-compose.yml` (e.g. `Jwt__Key`, `ConnectionStrings__DefaultConnection`).
- New config keys follow the `Section__Key` env-var convention used by the
  docker-compose file.
