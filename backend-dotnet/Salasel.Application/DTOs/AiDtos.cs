namespace Salasel.Application.DTOs;

// GET /api/v1/ai/recommendations
public class ProductRecommendationDto
{
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string Reason { get; set; } = string.Empty;
    public int CurrentQty { get; set; }
    public int ReorderThreshold { get; set; }

    // Best currently-listed offer for this product, if any supplier carries it.
    public int? RecommendedSupplierId { get; set; }
    public string? RecommendedSupplierName { get; set; }
    public decimal? RecommendedUnitPrice { get; set; }
    public int? RecommendedLeadTimeDays { get; set; }
}

// GET /api/v1/ai/next-order
public class NextOrderPredictionDto
{
    public int MerchantId { get; set; }
    public bool HasEnoughData { get; set; }
    public string? Message { get; set; }
    public DateTime? LastOrderDate { get; set; }
    public double? AverageIntervalDays { get; set; }
    public DateTime? PredictedNextOrderDate { get; set; }
}

// ─────────────────────────────────────────────────────────────────────────────
// AI-forwarding proxy payloads (POST /api/v1/ai/chat, /order/{id}, /voice/order/{id}).
// These mirror the ai_service schemas (snake_case over the wire) so the backend
// can forward client requests to the FastAPI service and relay its response
// untouched. See ai_service/app/schemas/{chat,order}.py.
// ─────────────────────────────────────────────────────────────────────────────

/// <summary>Request payload for POST /api/v1/ai/chat → ai_service POST /api/v1/chat.</summary>
public class ChatRequestPayload
{
    public string SessionId { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;

    /// <summary>[lat, lon] when the caller knows the customer's location.</summary>
    public double[]? CustomerLocation { get; set; }
}

/// <summary>Request payload for POST /api/v1/ai/order/{merchantId} → ai_service POST /api/v1/order/{merchantId}.</summary>
public class OrderRequestPayload
{
    public string Transcript { get; set; } = string.Empty;
    public double? Lat { get; set; }
    public double? Lon { get; set; }
}

/// <summary>
/// Raw proxy transport result: the ai_service status code plus its JSON body,
/// relayed to the backend caller without reshaping.
/// </summary>
public class AiProxyResponse
{
    public int StatusCode { get; set; }
    public string Body { get; set; } = string.Empty;

    public bool IsSuccess => StatusCode is >= 200 and < 300;
}