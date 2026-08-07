# Architecture — Salasel .NET Backend

System & module design for the Salasel core backend. This is the design
reference; `AGENTS.md` in this directory is the implementation contract
(commands, conventions, rules to respect). The repo root `README.md` describes
the product as a whole.

**Stack:** .NET 10, ASP.NET Core Web API, EF Core 10 + SQL Server,
FluentValidation, Serilog + Seq, SignalR, JWT bearer auth.

---

## 1. Overview

The backend is the authoritative, transactional core of Salasel. It owns all
product, supplier, merchant, and order data (SQL Server via EF Core), exposes a
REST API for the Angular supplier dashboard and the Flutter merchant app,
drives real-time notifications over SignalR, and runs queued background
pipelines (voice procurement and knowledge-base indexing). It is structured as
a strict **Onion / Clean Architecture**, keeping the domain and business rules
free of infrastructure concerns.

The design principle is separation: controllers only translate HTTP ↔ service
calls; service interfaces define the business contract; implementations in
`Infrastructure` touch EF/IO/AI; and AI reasoning is never inlined — it is
delegated to the external `ai_service` via the typed `IAIService`/`IAISyncService`
HTTP clients.

---

## 2. Solution architecture

```
            ┌─────────────────────────── Salasel.API ────────────────────────────┐
            │ Controllers      Middlewares         Program.cs / DI    SignalR    │
            │ (HTTP ↔ service) (GlobalException,   (composition root)  hub       │
            │                  Langfuse)                                         │
            └─────────┬──────────────────────────────────────────────────────────┘
                      │
    ┌─────────────────▼─────────┐          ┌────────────────────────────────────┐
    │  Salasel.Application      │          │  Salasel.Infrastructure           │
    │  DTOs, service interfaces │──depends─▶│  EF DbContext + Migrations        │
    │  business logic,          │          │  Repositories                     │
    │  validators               │          │  Worker pipelines, queues         │
    └────────────┬──────────────┘          │  NotificationHub (SignalR)        │
                 │ depends                 │  Email, IAIService/AISyncService  │
    ┌────────────▼──────────────┐          └────────────────────┬───────────────┘
    │  Salasel.Domain           │                               │ EF
    │  Entities + Enums (pure)  │                               ▼
    └───────────────────────────┘               ┌───────────────────────────────┐
                                                │  SQL Server (source of truth) │
                                                └───────────────────────────────┘
   (external)  ai_service (FastAPI) ──Qdrant snapshot, LLM reasoning, Kafka/HTTP──┐
```

### Dependency rules

| Layer | May reference | Must NOT reference |
| ----- | ------------- | ------------------ |
| `Domain` | nothing (pure CLR) | anything outside itself |
| `Application` | `Domain` | `Infrastructure`, `API`, EF types |
| `Infrastructure` | `Domain`, `Application` (interfaces) | `API` |
| `API` | all others | — |

Committing a cross-layer reference fails the build and must be fixed — never
work around it.

---

## 3. Module map

Mapped from the controllers / DTOs / entities / repositories that exist in the
solution.

| Module | Main controllers | Core entities | Notes |
| ------ | ---------------- | ------------- | ----- |
| **Auth & users** | `AuthController`, `UsersController` | `User` (with `TokenVersion`) | JWT issue, login, register, logout; revocation via `TokenVersion` claim check. |
| **Merchants** | `MerchantsController` | `MerchantsProfile` | Merchant profiles, dashboard. |
| **Suppliers** | `SuppliersController`, `SuppliersMeController`, `SupplierRolesController` | `SupplierProfile`, `SupplierWarehouse` | Supplier self-service & management, roles. |
| **Products / catalog** | `ProductsController`, `CatalogsController`, `CategoriesController` | `Product`, `Category`, `SupplierProduct` | Catalog upload & product listing; `SupplierProduct` links suppliers & prices. |
| **Inventory** | `InventoryController` | `MerchantInventory` | Per-merchant stock, reorder, alerts. |
| **Orders** | `OrdersController`, `ProcurementController`, `VoiceOrdersController` | `MasterOrder`, `SubOrder` | Order lifecycle, fulfillment, `OrderQueryService` / `OrderExecutionService`. |
| **Bidding** | (`BiddingController`) | `Bid`, `MasterOrder`/`SubOrder` | RfQ creation → supplier bidding → accept. |
| **Notifications** | `NotificationsController` | `Notification`, `UserNotificationSettings` | Preferences per user; live push over SignalR via `NotificationService`. |
| **Knowledge base / RAG** | `AdminKnowledgeBaseController`, `SupplierKnowledgeController` | `KnowledgeBaseArticle`, `SupplierKnowledgeDocument` | Enqueued to `KnowledgeIndexingQueue` → `KnowledgeIndexingWorker`. |
| **AI surface** | `AiController` | `AiOrderResult` (Infra model) | AI-facing endpoints aligned with `ai_service` schemas. |
| **Voice** | `VoiceController`, `VoiceOrdersController`, `LookupsController` | `VoiceProcurementLog`, `MasterOrder` (`Source = Voice`) | Voice-first procurement via `BackgroundQueue` + `VoiceProcessingWorker`. |
| **Search / lookups / public** | `SearchController`, `AppLookupsController`, `PublicController` | `ContactMessage` | Discovery, app lookups, public contact. |
| **Admin / dashboard** | `AdminController` | `DashboardDto` | Admin surface. |

---

## 4. Domain model (core relationships)

- `User` → `MerchantsProfile` (1:1) and `SupplierProfile` (1:1).
- `MasterOrder` → `Merchant` (N:1) and → `SubOrder` (1:N); a `SubOrder` may be
  fulfilled as a `Bid` or via `SupplierProduct` assignment.
- `SupplierProfile` → `Product` via `SupplierProduct` (many-to-many, carries
  price/qty/availability).
- `Product` → `Category` (N:1).
- `MerchantInventory` tracks per-merchant stock; `VoiceProcurementLog` is linked
  to a `MasterOrder` when a voice request is materialized.
- `KnowledgeBaseArticle` / `SupplierKnowledgeDocument` are indexed async.

Key enums (`Salasel.Domain/Enums/Enums.cs`): `OrderSource` (`Voice | Manual |
AI_Auto`), `ApprovalStatus`, `PaymentMethod`, `PaymentStatus`.

---

## 5. Background pipelines

Two queued HostedService worker patterns (see `AGENTS.md` §7 for rules):

1. **Voice procurement** — `VoiceController` enqueues raw requests onto
   `BackgroundQueue` (singleton). `VoiceProcessingWorker` drains the queue,
   uploads the audio to `ai_service` via `IAIService`
   (`POST /api/v1/voice/order/{merchantId}`), persists a `VoiceProcurementLog`,
   then materializes a `MasterOrder` (`Source = Voice`) + `SubOrder`s. Progress
   updates flow over SignalR via `NotificationService`.
2. **Knowledge indexing** — RAG document indexing jobs enqueued via
   `KnowledgeIndexingQueue` and run by `KnowledgeIndexingWorker`.

Both are wired as singleton queue + `AddHostedService` in `Program.cs`, and
both are designed to be idempotent on retry so failures can be replayed without
duplicate side effects.

---

## 6. EF Core & migrations operational model

- `SalaselDbContext` (`Salasel.Infrastructure/Data/`) is the single mapped
  context; every entity is registered here plus covered by a migration.
- Migrations are **never hand-edited** — generated with
  `dotnet ef migrations add <Name> -p Salasel.Infrastructure -s Salasel.API`.
- On startup the API runs `db.Database.Migrate()` wrapped so a DB outage does
  **not** kill the process (`Program.cs:187-210`); `/api/diagnostics` then
  reports the failure. This keeps nginx and healthchecks alive during a DB
  hiccup — do not change it to throw.
- CI auto-generates missing migrations on push to `main`
  (`.github/workflows/Deploy.yml`), committing any model diff back as
  `chore: auto-generate missing EF Core migration [skip ci]`.

---

## 7. HTTP / middleware pipeline

Order of registration in `Program.cs`:

`GlobalExceptionMiddleware` → `LangfuseMiddleware` → static files → Serilog
request logging → CORS (`AllowAll`) → `UseAuthentication` →
`UseAuthorization` → hubs + controllers + `/health` + `/api/diagnostics`.

- `GlobalExceptionMiddleware` normalizes unexpected exceptions into a
  consistent JSON shape — don't use it for control flow.
- `LangfuseMiddleware` traces requests for LLM/agent observability.
- Swagger / `/health` and the live-migration-report `/api/diagnostics` are
  available in both Development and Production.

---

## 8. Integration contract with `ai_service`

- The backend is the **source of truth** for products, suppliers, and quality.
  It pushes product create/update and quality metrics to the `ai_service`
  admin endpoints, which maintain a Qdrant snapshot (see
  `ai_service/architecture.md` §4). Do not add a second source of truth. The
  catalog is pushed best-effort on startup by `CatalogSyncWorker` and on
  demand via `POST /api/v1/admin/ai/sync-catalog`.
- Voice orders hit the service through the typed `IAIService` HTTP client
  (`POST /api/v1/voice/order/{merchantId}`); `AIService` is that client —
  AI reasoning stays entirely in `ai_service`.
- `AiController.cs` / `AiDtos.cs` keep the AI-facing surface aligned with the
  `ai_service` schemas; the LangGraph multi-agent conversation lives entirely
  in the `ai_service` service.
- Full integration reference (endpoints, config, sync, testing):
  `docs/ai-service-integration.md`.

---

## 9. Infrastructure (docker-compose)

Local dev stack lives in `backend-dotnet/docker-compose.yml`; one
`docker compose up -d --build` brings up:

- `sqlserver` (SQL Server 2022) — the transactional store, port 1433.
- `seq` — structured log viewer at :5342 (UI) with ingestion at `Seq:Url`.
- `api` — the Salasel image, wired to the above.
- `redis` — ai_service state store, port 6379.
- `qdrant` — ai_service vector DB, ports 6333/6334.
- `ai_service` — the FastAPI service (built from `../ai_service`), port 8000,
  reached by the API at `AiService__BaseUrl=http://ai_service:8000`.

Environment (`Section__Key` convention): `ConnectionStrings__DefaultConnection`,
`Jwt__Key` / `Jwt__Issuer` / `Jwt__Audience`, `Seq__Url`,
`AiService__BaseUrl`. Secrets come from
environment variables injected by docker-compose / CI, never committed.