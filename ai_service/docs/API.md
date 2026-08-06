# Salasel AI Service — API Reference

Base URL: `http://127.0.0.1:8000/api/v1`

All endpoints return JSON. There is no authentication on these routes yet.
Requests and responses are UTF-8.

## Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/health` | Service health (Redis reachability) |
| POST | `/chat` | Multi-turn agent conversation |
| POST | `/voice/transcribe` | Speech-to-text (audio → text) |
| POST | `/voice/chat` | Speech-to-text + agent turn in one call |
| POST | `/voice/order/{merchant_id}` | Speech-to-text → order schema draft |
| POST | `/order/{merchant_id}` | Text (JSON) → order schema draft (STT-free) |
| POST | `/admin/products` | Backend product ingestion → Qdrant |
| POST | `/admin/quality-metrics` | Compute + push quality scores from raw metrics |
| GET | `/admin/products` | Browse Qdrant product points (filter + paginate) |
| GET | `/admin/products/all` | Dump the full Qdrant catalog (all points, payload-only) |
| GET | `/admin/products/{product_id}` | Single Qdrant product point (payload ± vector) |
| GET | `/admin/collection` | Qdrant collection overview (count/dimension/distance) |

Interactive docs are also available while the service runs:
[Swagger UI](http://127.0.0.1:8000/docs) and
[ReDoc](http://127.0.0.1:8000/redoc), plus the raw spec at
`/openapi.json`.

---

## GET /health

Returns whether Redis is reachable.

```powershell
Invoke-RestMethod http://127.0.0.1:8000/api/v1/health
```

```bash
curl http://127.0.0.1:8000/api/v1/health
```

Response `200`:

```json
{"status": "ok", "redis": true}
```

| Field | Type | Description |
|---|---|---|
| `status` | string | `"ok"` when all dependencies pass, else `"degraded"` |
| `redis` | boolean | Redis reachable |

---

## POST /chat

Send a message in a multi-turn conversation. The same `session_id` continues
the same session (it maps to the LangGraph `thread_id`); a fresh
`session_id` starts a new conversation. Sessions are persisted in Redis, so a
service restart mid-conversation resumes correctly.

```bash
curl -X POST http://127.0.0.1:8000/api/v1/chat \
  -H "Content-Type: application/json" \
  -d '{"session_id": "test-1", "message": "I need PPE under 5 dollars", "customer_location": [30.0444, 31.2357]}'
```

### Request — `ChatRequest`

```json
{
  "session_id": "string",
  "message": "string",
  "customer_location": [30.0444, 31.2357]
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `session_id` | string | yes | Session / conversation identifier |
| `message` | string | yes | The customer's message |
| `customer_location` | array `[lat, lon]` | no | Customer location; enables geo-radius retrieval |

### Response — `ChatResponse`

```json
{
  "response": "What is your minimum budget for this product?",
  "spec": {
    "category": "PPE",
    "price_min": null,
    "price_max": null,
    "required_attributes": {},
    "is_complete": false,
    "needs_attribute_lookup": false
  },
  "turn_status": "ask",
  "missing_fields": ["price_min", "price_max"],
  "ranked_results": []
}
```

| Field | Type | Description |
|---|---|---|
| `response` | string | The agent's reply for this turn |
| `spec` | `ProductSpec` | Current extracted requirements (see below) |
| `turn_status` | string | Phase of the pipeline: `ask`, `retrieve`, `confirm`, `done`, or `rerank` |
| `missing_fields` | array of string | Required fields the agent still needs (`category`, `price_min`, `price_max`) |
| `ranked_results` | array of `Candidate` | Up to 5 ranked matches once the spec is complete |

### Session flow

- **New session** — the graph starts fresh with the given message.
- **Existing session, no pending decision** — the message is appended and the
  conversation continues.
- **Existing session, pending review** — the graph is paused at the review
  gate with ranked results. The next message decides:
  - Contains `yes`, `confirm`, `accept`, `approve`, or `looks good` →
    confirm (finishes the turn).
  - Anything else → reject; the reason text adjusts ranking weights and the
    retriever re-runs.
- When `customer_location` is omitted, the agent asks for a location before
  running a geo-radius search.

### Example full flow

Turn 1 (`session_id: "test-1"`, message `"I need PPE"`):

```json
{
  "response": "What is your minimum budget for this product?",
  "spec": {"category": "PPE", "price_min": null, "price_max": null},
  "turn_status": "ask",
  "missing_fields": ["price_min", "price_max"],
  "ranked_results": []
}
```

Turn 2 (same `session_id`, message `"between 2 and 5 dollars"`):

```json
{
  "response": "Here are your top matches...",
  "spec": {"category": "PPE", "price_min": 2, "price_max": 5},
  "turn_status": "confirm",
  "missing_fields": [],
  "ranked_results": [
    {
      "product_id": "1",
      "supplier_id": "1",
      "similarity_score": 0.71,
      "quality_score": 2.83,
      "distance_km": 0.0,
      "price": 3.75
    }
  ]
}
```

Turn 3 (same `session_id`, message `"confirm"`) — resumes the review gate and
finishes the turn.

---

## POST /voice/transcribe

Transcribe an audio file to text. Sends the file as multipart form data.

Supported formats: `m4a`, `mp3`, `wav`, `webm`, `ogg`, `flac`, `mp4`,
`mpeg`, `mpga`. Maximum upload size: 25 MB. Language is auto-detected
(Arabic and English supported) unless `STT_LANGUAGE` is set.

```bash
curl -X POST http://127.0.0.1:8000/api/v1/voice/transcribe \
  -F "audio=@recording.m4a"
```

### Request (multipart)

| Field | Type | Required | Description |
|---|---|---|---|
| `audio` | file | yes | The audio file to transcribe |

### Response — `TranscribeResponse`

```json
{"text": "I need PPE with a budget between 2 and 5 dollars", "language": "ar"}
```

| Field | Type | Description |
|---|---|---|
| `text` | string | Transcribed text |
| `language` | string | Detected ISO-639-1 language code (empty when unavailable) |

### Errors

| Status | Trigger |
|---|---|
| `413` | Audio file larger than the 25 MB limit |
| `415` | Unsupported audio format |
| `422` | Empty payload or no speech detected |
| `500` | Speech-to-text provider failure |

---

## POST /voice/chat

Transcribe an audio file and run it through the agent pipeline in one call.
Same session semantics as `/chat` — reuse `session_id` to continue a
conversation.

```bash
curl -X POST http://127.0.0.1:8000/api/v1/voice/chat \
  -F "audio=@recording.m4a" \
  -F 'request={"session_id": "voice-1", "customer_location": [30.0444, 31.2357]}'
```

### Request (multipart)

| Field | Type | Required | Description |
|---|---|---|---|
| `audio` | file | yes | The audio file to transcribe |
| `request` | string | yes | JSON-encoded `VoiceChatRequest` |

`VoiceChatRequest`:

| Field | Type | Required | Description |
|---|---|---|---|
| `session_id` | string | yes | Session / conversation identifier |
| `customer_location` | array\<number\> | no | `[lat, lon]` — enables geo-radius retrieval |

### Response

Returns the same `ChatResponse` shape as `POST /chat`.

### Errors

Same as `/voice/transcribe` for the transcription stage, plus:

| Status | Trigger |
|---|---|
| `422` | `request` is not valid JSON, or `customer_location` is not a `[lat, lon]` pair |
| `500` | Agent (graph) pipeline failure |

---

## POST /voice/order/{merchant_id}

Transcribe an audio recording and generate a draft order schema matching the
backend's `OrderExecutionRequestDto`. Runs a dedicated 5-node LangGraph pipeline:
extract requested products (LLM) → enrich with RAG metadata from Qdrant →
resolve defaults (user-specified value wins, else catalog/default) → match each
product to the best vector-store match → assemble the order schema
deterministically (no LLM in the final aggregation, so totals are never
invented).

```bash
curl -X POST "http://127.0.0.1:8000/api/v1/voice/order/42?lat=30.04&lon=31.24" \
  -F "audio=@order.wav"
```

### Path parameter

| Parameter | Type | Required | Description |
|---|---|---|---|
| `merchant_id` | integer | yes | Merchant creating the order |

### Query parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lat` | number | no | Merchant latitude — enables near-match ranking |
| `lon` | number | no | Merchant longitude (must be provided with `lat`) |

`lat`/`lon` must be passed together; a single coordinate returns `422`.

### Response — `OrderResponse`

| Field | Type | Description |
|---|---|---|
| `merchant_id` | integer\|null | Echoes the request merchant |
| `total_order_cost` | number | Sum of all split subtotals |
| `splits` | array | One entry per matched product |
| `unresolved` | array of string | Product names that could not be matched, surfaced for review (never silently dropped) |

```json
{
  "merchant_id": 42,
  "total_order_cost": 18.75,
  "splits": [
    {
      "supplier_id": 10,
      "sku": "NG-M",
      "quantity_ordered": 5,
      "sub_total_cost": 18.75
    }
  ],
  "unresolved": []
}
```

`splits[].supplier_id` / `sku` / `quantity_ordered` / `sub_total_cost` map to
the backend `OrderSplitDto`.

### Errors

Same as `/voice/transcribe` for the transcription stage, plus:

| Status | Trigger |
|---|---|
| `422` | Non-integer `merchant_id`, or `lat`/`lon` provided without the other |
| `500` | Order graph failure |

---

## POST /order/{merchant_id}

Text alternative to `/voice/order/{merchant_id}` — the same 5-node order
pipeline, but the transcript is taken from the JSON body instead of being
transcribed from audio. Response shape is identical (`OrderResponse`).

```bash
curl -X POST http://127.0.0.1:8000/api/v1/order/42 \
  -H "Content-Type: application/json" \
  -d '{"transcript": "five boxes of nitrile gloves, one hundred KN95 masks", "lat": 30.04, "lon": 31.24}'
```

### Request — `OrderTextRequest`

| Field | Type | Required | Description |
|---|---|---|---|
| `transcript` | string | yes | Order description in natural language (non-empty) |
| `lat` | number | no | Merchant latitude — enables near-match ranking |
| `lon` | number | no | Merchant longitude (must be provided with `lat`) |

`lat`/`lon` must be passed together; a single coordinate returns `422`. An
empty or whitespace-only `transcript` also returns `422`.

### Response — `OrderResponse`

Same shape as `/voice/order/{merchant_id}` (see above).

### Errors

| Status | Trigger |
|---|---|
| `422` | Empty `transcript`, non-integer `merchant_id`, or `lat`/`lon` provided without the other |
| `500` | Order graph failure |

---

## POST /admin/products

Production ingestion endpoint. The backend (.NET) pushes a batch of products;
the AI service embeds each one (name, SKU, category, description, attributes)
and upserts it into Qdrant, idempotent by `product_id` (re-pushing the same
product overwrites, never duplicates). `quality_score` is stored as `null` —
populate it with `/admin/quality-metrics`.

```bash
curl -X POST http://127.0.0.1:8000/api/v1/admin/products \
  -H "Content-Type: application/json" \
  -d '{"products": [{"product_id": 1, "supplier_id": 1, "product_name": "Nitrile Gloves Medium", "sku": "NG-MED", "category": "PPE", "description": "Disposable exam gloves", "attributes": {"size": "M"}, "price": 3.75, "lat": 30.04, "lon": 31.24, "in_stock": true}]}'
```

### Request — `ProductUpsertBatch`

```json
{
  "products": [
    {
      "product_id": 1,
      "supplier_id": 1,
      "product_name": "Nitrile Gloves Medium",
      "sku": "NG-MED",
      "category": "PPE",
      "description": "Disposable exam gloves",
      "attributes": {"size": "M"},
      "price": 3.75,
      "lat": 30.04,
      "lon": 31.24,
      "in_stock": true
    }
  ]
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `product_id` | integer | yes | Product identifier (also the Qdrant point ID) |
| `supplier_id` | integer | yes | Supplier identifier |
| `product_name` | string | yes | Product name — part of the embedding text |
| `sku` | string | no | Stock-keeping unit — part of the embedding text |
| `category` | string | no | Category, e.g. `"PPE"` — filter + embedding |
| `description` | string | no | Product description — part of the embedding text |
| `attributes` | object | no | Category-specific attributes — filter/embedding |
| `price` | number | no | Unit price — price-range filter + display |
| `lat` | number | no | Supplier latitude — geo filter + distance |
| `lon` | number | no | Supplier longitude |
| `in_stock` | boolean | no | Availability flag — `false` excludes from RAG listing |

Response `200`:

```json
{"status": "ok", "synced": 1}
```

---

## POST /admin/quality-metrics

The backend pushes raw review metrics; the AI service computes quality scores
(blending each supplier's average rating toward the batch global average,
then combining rating / on-time delivery / defect signals) and applies
payload-only updates to every product of that supplier in Qdrant — no
re-embedding.

```bash
curl -X POST http://127.0.0.1:8000/api/v1/admin/quality-metrics \
  -H "Content-Type: application/json" \
  -d '{"metrics": [{"supplier_id": 1, "review_count": 50, "average_rating": 4.5, "on_time_delivery_rate": 0.95, "defect_rate": 0.02}]}'
```

### Request — `QualityMetricsBatch`

| Field | Type | Required | Description |
|---|---|---|---|
| `supplier_id` | integer | yes | Supplier identifier |
| `review_count` | integer | no | Number of reviews (weights trust in the average) |
| `average_rating` | number | no | Average rating (0–5) |
| `on_time_delivery_rate` | number | no | Fraction of on-time deliveries (0–1) |
| `defect_rate` | number | no | Fraction of defective items (0–1) |

Response `200`:

```json
{"status": "ok", "updated_suppliers": 1}
```

---

## GET /admin/products

Read-only browse of the Qdrant `products` collection (payloads, optionally the
embedding vectors). Paginated with integer `offset` — "start from this point
ID". Does not modify the vector store.

```bash
curl "http://127.0.0.1:8000/api/v1/admin/products?category=PPE&limit=10&offset=0"
```

### Query parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `category` | string | — | Filter by category |
| `supplier_id` | integer | — | Filter by supplier (`≥ 1`) |
| `in_stock` | boolean | — | Filter by `in_stock` flag |
| `price_min` | number | — | Lower price bound (`≥ 0`) |
| `price_max` | number | — | Upper price bound (`≥ 0`) |
| `offset` | integer | `0` | Start from this point ID (for pagination) |
| `limit` | integer | `50` | Max points to return (`1`–`1000`) |
| `with_vectors` | boolean | `false` | Include the `384`-dim embedding per point |

Response `200`:

```json
{
  "items": [
    {
      "id": 1,
      "product_id": "1",
      "supplier_id": "1",
      "product_name": "Nitrile Gloves Medium",
      "sku": "NG-MED",
      "category": "PPE",
      "description": "Disposable exam gloves",
      "attributes": {"size": "M"},
      "price": 3.75,
      "geo": {"lat": 30.04, "lon": 31.24},
      "quality_score": 90.0,
      "in_stock": true
    }
  ],
  "total": 1,
  "offset": 0,
  "limit": 10
}
```

Each item is the point payload plus its integer `id` (`product_id`). `total` is
the count matching the filters independent of `offset`/`limit`.

### Errors

| Status | Trigger |
|---|---|
| `422` | Invalid query value (e.g. `supplier_id=0`, `limit=2000`) |

---

## GET /admin/products/all

Return the **entire** Qdrant catalog in one response — no filters, no manual
pagination. Internally follows Qdrant's cursor until the collection is fully
scanned, so it returns every point regardless of catalog size.

```bash
curl "http://127.0.0.1:8000/api/v1/admin/products/all"
```

Payload-only: embeddings are not included (all points would otherwise bloat the
response with thousands of 384-dim floats).

Response `200`:

```json
{
  "items": [
    {
      "id": 1,
      "product_id": "1",
      "supplier_id": "1",
      "product_name": "Nitrile Gloves Medium",
      "sku": "NG-MED",
      "category": "PPE",
      "price": 3.75,
      "geo": {"lat": 30.04, "lon": 31.24},
      "quality_score": 2.68,
      "in_stock": true
    }
  ],
  "total": 10
}
```

`items` uses the same shape as `/admin/products`, and `total` equals
`len(items)`.

---

## GET /admin/products/{product_id}

Read a single product point by ID (the integer `product_id`, which is also the
Qdrant point ID).

```bash
curl "http://127.0.0.1:8000/api/v1/admin/products/1?with_vectors=true"
```

Response `200` is the same item shape as the list endpoint (with `vector` added
when `with_vectors=true`). `404` when the point does not exist; `422` for a
non-integer `product_id`.

---

## GET /admin/collection

High-level overview of the Qdrant collection: current point count and vector
configuration.

```bash
curl http://127.0.0.1:8000/api/v1/admin/collection
```

Response `200`:

```json
{"collection": "products", "count": 12, "dimension": 384, "distance": "Cosine"}
```

---

## Schemas

### ProductSpec

| Field | Type | Description |
|---|---|---|
| `category` | string \| null | Product category, e.g. `"PPE"` |
| `price_min` | number \| null | Minimum budget |
| `price_max` | number \| null | Maximum budget |
| `required_attributes` | object | Category-specific key/value attributes |
| `is_complete` | boolean | True when `category`, `price_min`, and `price_max` are set |
| `needs_attribute_lookup` | boolean | True when the agent needs a RAG attribute lookup before continuing |

### Candidate

| Field | Type | Description |
|---|---|---|
| `product_id` | string | Product identifier |
| `supplier_id` | string | Supplier identifier |
| `similarity_score` | number | Vector similarity (0–1) from Qdrant |
| `quality_score` | number | Blend of rating/delivery/defect signals (max ≈ 3; see `/admin/quality-metrics`) |
| `distance_km` | number | Distance from the customer's location |
| `price` | number | Product price |

### ChatRequest

| Field | Type | Required | Description |
|---|---|---|---|
| `session_id` | string | yes | Session / conversation identifier |
| `message` | string | yes | The customer's message |
| `customer_location` | array `[lat, lon]` | no | Customer location |

### VoiceChatRequest

| Field | Type | Required | Description |
|---|---|---|---|
| `session_id` | string | yes | Session / conversation identifier |
| `customer_location` | array `[lat, lon]` | no | Customer location |

### ChatResponse

| Field | Type | Description |
|---|---|---|
| `response` | string | The agent's reply |
| `spec` | `ProductSpec` | Current extracted requirements |
| `turn_status` | string | `ask`, `retrieve`, `confirm`, `done`, or `rerank` |
| `missing_fields` | array of string | Missing required fields |
| `ranked_results` | array of `Candidate` | Up to 5 ranked matches |

### OrderResponse

| Field | Type | Description |
|---|---|---|
| `merchant_id` | integer\|null | Echoes the request merchant |
| `total_order_cost` | number | Sum of all split subtotals |
| `splits` | array of `OrderSplit` | One entry per matched product |
| `unresolved` | array of string | Product names that could not be matched (surfaced, never dropped) |

### OrderSplit

| Field | Type | Description |
|---|---|---|
| `supplier_id` | integer | Supplier identifier |
| `sku` | string | Matched product SKU |
| `quantity_ordered` | integer | Quantity for this line |
| `sub_total_cost` | number | `quantity × unit_price` for this line |

### TranscribeResponse

| Field | Type | Description |
|---|---|---|
| `text` | string | Transcribed text |
| `language` | string | Detected ISO-639-1 language code |

### HealthResponse

| Field | Type | Description |
|---|---|---|
| `status` | string | `"ok"` or `"degraded"` |
| `redis` | boolean | Redis reachable |

---

## Error Handling

| Status | Trigger |
|---|---|
| `400` | Malformed request (FastAPI validation) |
| `413` | Audio file too large (voice endpoints) |
| `415` | Unsupported audio format (voice endpoints) |
| `422` | Validation failure — missing field, empty/no-speech transcript, bad `customer_location`, non-integer `/voice/order` `merchant_id`, or partial `lat`/`lon` |
| `500` | Speech-to-text provider failure or agent pipeline failure |

Error bodies follow FastAPI's convention:

```json
{"detail": "Audio file exceeds the 26214400 byte limit"}
```
