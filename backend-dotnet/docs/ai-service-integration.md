# AI Service Integration — Salasel .NET Backend ⇄ ai_service

How the Salasel core backend talks to the external FastAPI `ai_service`
(`../ai_service`). The FastAPI endpoint contract is documented in
`../ai_service/docs/API.md`; this file covers the **backend side**: what the
.NET service calls, why, and how to configure/test it.

**Principle:** the backend is the source of truth for products, suppliers, and
orders. AI reasoning (LLM, RAG, Qdrant retrieval, ranking) lives entirely in
`ai_service`. The backend only **forwards** requests and **pushes** catalog
data — it never inlines AI logic.

---

## 1. Responsibilities split

| Concern | Owner |
| --- | --- |
| Products, suppliers, merchants, orders (persistence) | .NET + SQL Server |
| Voice transcription, intent/entity extraction, ranking | `ai_service` (FastAPI + LangGraph) |
| Vector index (Qdrant snapshot of the catalog) | `ai_service`, seeded/pushed by the backend |
| Order lifecycle (draft → approve → ship → deliver) | .NET |
| AI-facing relay endpoints | .NET (`/api/v1/ai/*`) |

---

## 2. Configuration

Defined in `Salasel.API/appsettings.json` (and overridable per environment):

```json
"AiService": {
  "BaseUrl": "http://localhost:8000",
  "TimeoutSeconds": 120
}
```

| Key | Env override | Default | Meaning |
| --- | --- | --- | --- |
| `AiService:BaseUrl` | `AiService__BaseUrl` | `http://localhost:8000` | Base URL of the FastAPI service |
| `AiService:TimeoutSeconds` | `AiService__TimeoutSeconds` | `120` | Per-request HTTP timeout |

In `backend-dotnet/docker-compose.yml` the API container defaults to
`AiService__BaseUrl=http://ai_service:8000` — the compose network **service
name** — so the API reaches the containerized `ai_service` directly. Any
environment follows the `Section__Key` convention.

### Running both backends in Docker

The backend compose file ships the **full local dev stack** as one project:

| Service | Image / build | Port |
| --- | --- | --- |
| `sqlserver` | `mcr.microsoft.com/mssql/server:2022-latest` | 1433 |
| `seq` | `datalust/seq:latest` | 5342 |
| `api` | built from `backend-dotnet/Dockerfile` | 5000 |
| `redis` | `redis/redis-stack-server` | 6379 |
| `qdrant` | `qdrant/qdrant:latest` | 6333 / 6334 |
| `ai_service` | built from `../ai_service/infra/docker/Dockerfile` | 8000 |

Bring everything up with one command (from `backend-dotnet/`):

```powershell
docker compose up -d --build
```

The API reaches the AI service at `AiService__BaseUrl=http://ai_service:8000`
(compose network DNS — no `host.docker.internal` needed). `env_file` pulls in
`../ai_service/.env.example`, which keeps `SEED_ON_STARTUP=true`, so Qdrant is
auto-seeded with a small dev catalog on first start. Override the URL with an
`AI_SERVICE_URL` env var if you run `ai_service` elsewhere.

> For a host-based `dotnet run` dev loop, override the URL to
> `AiService__BaseUrl=http://localhost:8000` (or start ai_service from its own
> stack — see §10) and keep using the `dotnet run --project Salasel.API`
> workflow.

---

## 3. Typed HTTP clients

Registered in `Salasel.API/Program.cs` with `AddHttpClient<...>` and the base
address from `AiService:BaseUrl`:

| Client | Implementation | Purpose |
| --- | --- | --- |
| `IAIService` | `AIService` (`Salasel.Infrastructure/Services/AIService.cs`) | Chat / text-order / voice-order forwarding + audio upload for the voice pipeline |
| `IAISyncService` | `AISyncService` (`Salasel.Infrastructure/Services/AISyncService.cs`) | Push the live catalog into Qdrant via `/admin/products` |

Both are resolved per-request/scoped (safe to inject into hosted workers via
`IServiceScopeFactory`).

---

## 4. Endpoints: backend → ai_service

### 4.1 Public relay proxies (`AiController`, route `/api/v1/ai`)

Thin, **anonymous** relays that forward the client's request unchanged and
return the ai_service response body **verbatim** (raw JSON). Non-2xx responses
are relayed with their original status code and body (e.g. `422` on an empty
transcript). Request payloads are serialized **snake_case** to match pydantic.

| Backend route | ai_service target | Request | Response |
| --- | --- | --- | --- |
| `POST /api/v1/ai/chat` | `POST /api/v1/chat` | `ChatRequestPayload` (JSON) | ai_service chat JSON |
| `POST /api/v1/ai/order/{merchantId}` | `POST /api/v1/order/{merchantId}` | `OrderRequestPayload` (JSON) | ai_service order JSON |
| `POST /api/v1/ai/voice/order/{merchantId}` | `POST /api/v1/voice/order/{merchantId}` | multipart `file` + query `lat`/`lon` | ai_service order JSON |

These exist so mobile/web clients can reach the AI assistant through the single
backend origin without talking to FastAPI directly.

### 4.2 Catalog sync (`AdminController`)

| Backend route | ai_service target | Notes |
| --- | --- | --- |
| `POST /api/v1/admin/ai/sync-catalog` | `POST /api/v1/admin/products` | Admin-only; forces a full resync (also runs once at startup) |

---

## 5. Voice processing pipeline (async, not a relay)

The merchant-facing voice flow is asynchronous and queue-based; it does **not**
use the relay endpoints above.

```
POST /api/voice/upload (multipart file + merchantId)
   │  saves audio to wwwroot/uploads, creates VoiceProcurementLog
   ▼
BackgroundQueue (singleton) ──> VoiceProcessingWorker (HostedService)
   │  IAIService.ProcessVoiceAsync(filePath, merchantId, lat, lng)
   │      → POST /api/v1/voice/order/{merchantId} (multipart field "audio")
   │      → OrderResponse { merchant_id, total_order_cost, splits[], unresolved[] }
   ▼
AiOrderResult (splits → line items; dominant supplier = PreferredSupplierId)
   │  SKU → product-name enrichment
   │  supplier = PreferredSupplierId ?? nearest routed supplier
   ▼
AIProcessing (ParsedJson) + MasterOrder (Source = Voice, AI_Draft) + SubOrder
   ▼
SignalR "DraftOrderReady" → merchant app (INotificationService)
```

Key points:

- The audio field name sent to ai_service is **`audio`** (matches
  `UploadFile = File(...)` in `ai_service/app/api/v1/voice.py`).
- `OrderResponse.splits` map to `AiOrderItem` lines: `Price =
  sub_total_cost / quantity_ordered`; `TotalOrderCost` is kept from the AI.
- A split's supplier that contributes the most to the total becomes
  `PreferredSupplierId`; the worker falls back to `ISupplierAssignmentService`
  (nearest routed supplier) when the AI returns no usable split.
- `unresolved` terms are carried on `AiOrderResult.Unresolved` (not persisted
  as order lines); an empty split list still creates a draft but with no
  supplier assigned, and `unresolved` is visible to the client.
- Failures notify the merchant via SignalR `ProcessingFailed` and are logged —
  they never crash the worker.

---

## 6. Catalog sync → Qdrant

`IAISyncService.SyncAllActiveProductsAsync()` reads every **active**
`SupplierProduct` whose supplier is `IsActiveForRouting` and whose product is
active, then POSTs one `ProductUpsertBatch` to `/api/v1/admin/products`
(idempotent upsert — re-syncing overwrites, never duplicates).

One Qdrant point per supplier-product listing with:

| Field | Source |
| --- | --- |
| `product_id` | `SupplierProduct.ProductId` |
| `supplier_id` | `SupplierProduct.SupplierId` |
| `product_name`, `sku`, `unit` | `Product` |
| `category` | `Product.Category.Name` |
| `description` | `Product.Description` |
| `price` | `SupplierProduct.UnitPrice` |
| `lat` / `lon` | `SupplierProfile.LocationLat/LocationLng` |
| `in_stock` | `SupplierProduct.AvailableQty > 0` |

**Triggers:**

- `CatalogSyncWorker` (HostedService) — best-effort, ~10s after startup, never
  blocks boot; failure is logged and the app keeps running.
- `POST /api/v1/admin/ai/sync-catalog` — manual re-run (Admin role).

If Qdrant is empty/out of date, ai_service returns fewer splits and more
`unresolved` items — re-run the sync after catalog changes.

---

## 7. DTO shape reference

Mirrors of the pydantic schemas (`ai_service/app/schemas/{chat,order,product}.py`).
Over the wire these are **snake_case**.

- `ChatRequestPayload` — `session_id`, `message`, `customer_location` (`[lat, lon]`).
- `OrderRequestPayload` — `transcript`, `lat`, `lon`.
- `AiProxyResponse` — `StatusCode` + `Body` (raw relay transport).
- `AiOrderResult` (`Salasel.Infrastructure/Models/AiOrderResult.cs`) — internal
  line-item model: `MerchantId`, `Items`, `TotalOrderCost`,
  `PreferredSupplierId`, `Unresolved`, `ModelUsed`.

---

## 8. Testing (curl)

Prerequisites: **both backends running in Docker** — `docker compose up -d --build`
from `backend-dotnet/` starts `api` (Docker origin `:5000`) and `ai_service`
(`:8000`) together — plus a merchant + routable supplier with products in the
DB. For a host-based loop, run `ai_service` in Docker and the API on the host
(`dotnet run --project Salasel.API` → `http://localhost:5039`), overriding
`AiService__BaseUrl=http://localhost:8000`.

Because `SEED_ON_STARTUP=true` auto-seeds Qdrant, a manual catalog sync is
optional — run it if you want live products:

```powershell
# 1. Backend + AI service health (Docker API on :5000, ai_service on :8000)
curl.exe http://localhost:5000/api/diagnostics
curl.exe http://localhost:8000/api/v1/health
curl.exe http://localhost:8000/api/v1/admin/collection   # Qdrant catalog size

# 2. (Admin) force catalog sync
$tok = (curl.exe -s -X POST http://localhost:5000/api/v1/auth/login `
  -H "Content-Type: application/json" `
  -d '{"email":"admin@salasel.dev","password":"..."}' | ConvertFrom-Json).Token
curl.exe -s -X POST http://localhost:5000/api/v1/admin/ai/sync-catalog -H "Authorization: Bearer $tok"

# 3. Relay proxies (public) — payloads mirror the current DTOs (snake_case)
# chat: message + optional customer_location [lat, lon] for location-aware ranking
curl.exe -X POST http://localhost:5000/api/v1/ai/chat -H "Content-Type: application/json" `
  -d '{"session_id":"t1","message":"20 boxes coca-cola","customer_location":[30.04,31.24]}'
# order: transcript + lat & lon (must be provided together — ai_service 422s if only one)
curl.exe -X POST http://localhost:5000/api/v1/ai/order/1 -H "Content-Type: application/json" `
  -d '{"transcript":"20 boxes coca-cola","lat":30.04,"lon":31.24}'
# voice/relay: the backend forwards the multipart "file" to ai_service's "audio" field
curl.exe -X POST "http://localhost:5000/api/v1/ai/voice/order/1?lat=30.04&lon=31.24" -F "file=@sample.mp3"

# 4. Async voice pipeline (merchant-facing, queue-based)
curl.exe -s -X POST http://localhost:5000/api/voice/upload -F "file=@sample.mp3" -F "merchantId=1"
curl.exe -s "http://localhost:5000/api/voice/uploads?merchantId=1"   # hasAi once processed
curl.exe -s "http://localhost:5000/api/voice-orders/1"               # draft order
curl.exe -s "http://localhost:5000/api/voice-orders/1/ai-insights"   # confidence/risk flags
```

> 422 edges to prove your payloads match the schemas: empty `message` (chat) or
> empty/whitespace `transcript` (order) → `422`; `lat`/`lon` must be sent
> together (either both or neither). The relay returns these status codes and
> bodies verbatim.
>
> **Host-mode dev loop** (`dotnet run --project Salasel.API`, ai_service on
> `:8000`) uses `http://localhost:5039` as the API origin instead of `:5000`.

---

## 9. Troubleshooting

| Symptom | Likely cause / fix |
| --- | --- |
| `502` from `/api/v1/admin/ai/sync-catalog` | `ai_service` not reachable. In Docker, check `docker compose ps` and `docker logs salasel-dev-ai`; verify `AiService__BaseUrl=http://ai_service:8000`. The startup worker logs this without crashing. |
| Voice upload processed but order has no items / all `unresolved` | Qdrant not seeded or catalog stale — run the catalog sync (startup or admin endpoint). |
| ai_service returns `422` on voice | Wrong multipart field name — backend always sends `audio`; verify `VoiceOrderAsync`. |
| Relays time out | Increase `AiService:TimeoutSeconds`; FastAPI does live LLM/STT calls. |
| No `DraftOrderReady` on SignalR | Check `VoiceProcessingWorker` logs; the worker notifies `ProcessingFailed` on errors instead. |

---

## 10. Related docs

- FastAPI contract & examples: `../ai_service/docs/API.md`
- ai_service architecture (graph, Qdrant sync, ranking): `../ai_service/architecture.md`
- ai_service standalone Docker stack: `../ai_service/infra/docker/docker-compose.yml`
- Backend design: `../backend-dotnet/architecture.md`
- Implementation rules: `../backend-dotnet/AGENTS.md`
