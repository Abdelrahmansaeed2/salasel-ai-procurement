using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using Salasel.Application.DTOs;
using Salasel.Infrastructure.Models;

namespace Salasel.Infrastructure.Services;

/// <summary>
/// HTTP client for the external ai_service. The backend stays the source of truth
/// for products/suppliers and delegates AI reasoning to the service — never inline
/// AI logic in the backend.
/// </summary>
public interface IAIService
{
    /// <summary>
    /// Uploads an audio file to <c>POST /api/v1/voice/order/{merchantId}</c> and
    /// returns the parsed order (line items, preferred supplier, unresolved terms).
    /// </summary>
    Task<AiOrderResult> ProcessVoiceAsync(
        string filePath,
        int merchantId,
        double merchantLat,
        double merchantLng,
        CancellationToken ct = default);

    /// <summary>Proxy: forwards a chat message to <c>POST /api/v1/chat</c> and returns the raw response.</summary>
    Task<AiProxyResponse> ChatAsync(ChatRequestPayload request, CancellationToken ct = default);

    /// <summary>Proxy: forwards a text order to <c>POST /api/v1/order/{merchantId}</c> and returns the raw response.</summary>
    Task<AiProxyResponse> OrderAsync(int merchantId, OrderRequestPayload request, CancellationToken ct = default);

    /// <summary>Proxy: forwards an audio file to <c>POST /api/v1/voice/order/{merchantId}</c> and returns the raw response.</summary>
    Task<AiProxyResponse> VoiceOrderAsync(
        int merchantId,
        Stream audio,
        string fileName,
        double merchantLat,
        double merchantLng,
        CancellationToken ct = default);

    /// <summary>Proxy: forwards an audio file to <c>POST /api/v1/voice/transcribe</c> and returns the transcribed text.</summary>
    Task<string> TranscribeVoiceAsync(
        Stream audio,
        string fileName,
        CancellationToken ct = default);

    /// <summary>Uploads a knowledge document to <c>POST /api/v1/admin/knowledge/ingest</c> for RAG/Seeding.</summary>
    Task<AiProxyResponse> IngestKnowledgeAsync(
        int supplierId,
        string filePath,
        string fileName,
        double lat,
        double lon,
        CancellationToken ct = default);
}

public class AIService : IAIService
{
    private readonly HttpClient _http;
    private readonly ILogger<AIService> _logger;

    public AIService(HttpClient http, ILogger<AIService> logger)
    {
        _http = http;
        _logger = logger;
    }

    public async Task<AiOrderResult> ProcessVoiceAsync(
        string filePath,
        int merchantId,
        double merchantLat,
        double merchantLng,
        CancellationToken ct = default)
    {
        byte[] data = await File.ReadAllBytesAsync(filePath, ct);
        var fileName = Path.GetFileName(filePath);

        using var content = new MultipartFormDataContent();
        var fileContent = new ByteArrayContent(data);
        fileContent.Headers.ContentType =
            new System.Net.Http.Headers.MediaTypeHeaderValue("application/octet-stream");
        content.Add(fileContent, "audio", fileName);

        var url = $"/api/v1/voice/order/{merchantId}?lat={merchantLat}&lon={merchantLng}";
        _logger.LogInformation(
            "AIService: calling {Url} with {Bytes} bytes for merchant {MerchantId}",
            url, data.Length, merchantId);

        using var response = await _http.PostAsync(url, content, ct);
        var body = await response.Content.ReadAsStringAsync(ct);

        if (!response.IsSuccessStatusCode)
        {
            _logger.LogError(
                "AIService: {Method} {Url} returned {(int)response.StatusCode}: {Body}",
                HttpMethod.Post, url, (int)response.StatusCode, body);
            response.EnsureSuccessStatusCode();
        }

        var raw = JsonSerializer.Deserialize<VoiceOrderResponse>(body, JsonOptions);
        if (raw is null)
            throw new InvalidOperationException("ai_service returned an empty voice-order response.");

        _logger.LogInformation(
            "AIService: merchant {MerchantId} -> {Splits} splits, total {Total}, {Unresolved} unresolved",
            raw.MerchantId, raw.Splits.Count, raw.TotalOrderCost, raw.Unresolved.Count);

        return ToAiOrderResult(raw);
    }

    public async Task<AiProxyResponse> ChatAsync(
        ChatRequestPayload request,
        CancellationToken ct = default)
    {
        using var json = new StringContent(
            JsonSerializer.Serialize(request, ProxyJsonOptions),
            Encoding.UTF8,
            "application/json");

        _logger.LogInformation("AIService: forwarding chat for session {SessionId}", request.SessionId);
        return await SendRawAsync(() => _http.PostAsync("/api/v1/chat", json, ct), ct);
    }

    public async Task<AiProxyResponse> OrderAsync(
        int merchantId,
        OrderRequestPayload request,
        CancellationToken ct = default)
    {
        using var json = new StringContent(
            JsonSerializer.Serialize(request, ProxyJsonOptions),
            Encoding.UTF8,
            "application/json");

        _logger.LogInformation("AIService: forwarding text order for merchant {MerchantId}", merchantId);
        return await SendRawAsync(() => _http.PostAsync($"/api/v1/order/{merchantId}", json, ct), ct);
    }

    public async Task<AiProxyResponse> VoiceOrderAsync(
        int merchantId,
        Stream audio,
        string fileName,
        double merchantLat,
        double merchantLng,
        CancellationToken ct = default)
    {
        using var content = new MultipartFormDataContent();
        var fileContent = new StreamContent(audio);
        fileContent.Headers.ContentType =
            new System.Net.Http.Headers.MediaTypeHeaderValue("application/octet-stream");
        content.Add(fileContent, "audio", fileName);

        var url = $"/api/v1/voice/order/{merchantId}?lat={merchantLat}&lon={merchantLng}";
        _logger.LogInformation(
            "AIService: forwarding voice order {FileName} for merchant {MerchantId}",
            fileName, merchantId);

        return await SendRawAsync(() => _http.PostAsync(url, content, ct), ct);
    }

    public async Task<string> TranscribeVoiceAsync(
        Stream audio,
        string fileName,
        CancellationToken ct = default)
    {
        using var content = new MultipartFormDataContent();
        var fileContent = new StreamContent(audio);
        fileContent.Headers.ContentType =
            new System.Net.Http.Headers.MediaTypeHeaderValue("application/octet-stream");
        content.Add(fileContent, "audio", fileName);

        var url = "/api/v1/voice/transcribe";
        _logger.LogInformation("AIService: forwarding voice transcription {FileName}", fileName);

        using var response = await _http.PostAsync(url, content, ct);
        var body = await response.Content.ReadAsStringAsync(ct);

        if (!response.IsSuccessStatusCode)
        {
            _logger.LogError("Transcribe error: {Body}", body);
            return ""; // Fallback
        }

        try {
            using var doc = JsonDocument.Parse(body);
            return doc.RootElement.GetProperty("text").GetString() ?? "";
        } catch {
            return "";
        }
    }

    public async Task<AiProxyResponse> IngestKnowledgeAsync(
        int supplierId,
        string filePath,
        string fileName,
        double lat,
        double lon,
        CancellationToken ct = default)
    {
        byte[] data = await File.ReadAllBytesAsync(filePath, ct);

        using var content = new MultipartFormDataContent();
        var fileContent = new ByteArrayContent(data);
        fileContent.Headers.ContentType =
            new System.Net.Http.Headers.MediaTypeHeaderValue("application/octet-stream");
        
        content.Add(fileContent, "file", fileName);
        content.Add(new StringContent(supplierId.ToString()), "supplier_id");
        content.Add(new StringContent(lat.ToString(System.Globalization.CultureInfo.InvariantCulture)), "lat");
        content.Add(new StringContent(lon.ToString(System.Globalization.CultureInfo.InvariantCulture)), "lon");

        var url = "/api/v1/admin/knowledge/ingest";
        _logger.LogInformation(
            "AIService: uploading knowledge document {FileName} for supplier {SupplierId} at lat={Lat}, lon={Lon}",
            fileName, supplierId, lat, lon);

        return await SendRawAsync(() => _http.PostAsync(url, content, ct), ct);
    }

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true
    };

    // Requests to ai_service must use snake_case to match pydantic field names
    // (session_id, customer_location, ...). See ai_service/app/schemas/*.py.
    private static readonly JsonSerializerOptions ProxyJsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower
    };

    private static async Task<AiProxyResponse> SendRawAsync(
        Func<Task<HttpResponseMessage>> send,
        CancellationToken ct)
    {
        using var response = await send();
        var body = await response.Content.ReadAsStringAsync(ct);

        if (!response.IsSuccessStatusCode)
        {
            // Log but don't throw — the caller relays the ai_service status/body
            // to the backend client (pure proxy).
            return new AiProxyResponse
            {
                StatusCode = (int)response.StatusCode,
                Body = body
            };
        }

        return new AiProxyResponse
        {
            StatusCode = (int)response.StatusCode,
            Body = body
        };
    }

    // ── DTOs mirroring ai_service schemas (app/schemas/order.py) ──
    private sealed class VoiceOrderResponse
    {
        public int? MerchantId { get; set; }
        public decimal TotalOrderCost { get; set; }
        public List<VoiceOrderSplit> Splits { get; set; } = new();
        public List<string> Unresolved { get; set; } = new();
    }

    private sealed class VoiceOrderSplit
    {
        public int SupplierId { get; set; }
        public string Sku { get; set; } = string.Empty;
        public int QuantityOrdered { get; set; }
        public decimal SubTotalCost { get; set; }
    }

    /// <summary>
    /// Maps the ai_service order response into the line-item model persisted by the
    /// backend (single aggregate SubOrder). Unit price is derived from
    /// sub_total/quantity; the dominant supplier split becomes the preferred supplier.
    /// </summary>
    private static AiOrderResult ToAiOrderResult(VoiceOrderResponse raw)
    {
        var result = new AiOrderResult
        {
            MerchantId = raw.MerchantId ?? 0,
            TotalOrderCost = raw.TotalOrderCost,
            Unresolved = raw.Unresolved,
            ModelUsed = "ai_service"
        };

        foreach (var split in raw.Splits)
        {
            var unitPrice = split.QuantityOrdered > 0
                ? split.SubTotalCost / split.QuantityOrdered
                : 0m;

            result.Items.Add(new AiOrderItem
            {
                ProductName = string.IsNullOrWhiteSpace(split.Sku) ? "Unknown item" : split.Sku,
                Quantity = split.QuantityOrdered,
                Price = unitPrice
            });
        }

        // Dominant supplier = the split contributing the most to the order total.
        result.PreferredSupplierId = raw.Splits
            .GroupBy(s => s.SupplierId)
            .OrderByDescending(g => g.Sum(s => s.SubTotalCost))
            .Select(g => g.Key)
            .FirstOrDefault();

        return result;
    }
}