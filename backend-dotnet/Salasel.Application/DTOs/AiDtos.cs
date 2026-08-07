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