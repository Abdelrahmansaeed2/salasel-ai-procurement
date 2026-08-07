using System.ComponentModel.DataAnnotations;

namespace Salasel.Infrastructure.Models;

// POST /api/voice-orders/{id}/items
public class AddDraftItemDto
{
    [Required, MinLength(1)]
    public string ProductName { get; set; } = string.Empty;

    [Range(1, int.MaxValue, ErrorMessage = "Quantity must be at least 1.")]
    public int Quantity { get; set; }

    [Range(0, double.MaxValue, ErrorMessage = "Price cannot be negative.")]
    public decimal Price { get; set; }
}

// PUT /api/voice-orders/{id}/items — itemId travels in the body, not the
// route, matching the API contract (only DELETE has {itemId} in the path).
public class UpdateDraftItemDto
{
    [Required]
    public string ItemId { get; set; } = string.Empty;

    [Required, MinLength(1)]
    public string ProductName { get; set; } = string.Empty;

    [Range(1, int.MaxValue, ErrorMessage = "Quantity must be at least 1.")]
    public int Quantity { get; set; }

    [Range(0, double.MaxValue, ErrorMessage = "Price cannot be negative.")]
    public decimal Price { get; set; }
}

// GET /api/voice-orders/{id}/ai-insights
public class AiInsightsDto
{
    public int OrderId { get; set; }
    public decimal Confidence { get; set; }
    public string ModelUsed { get; set; } = string.Empty;

    public int? SupplierId { get; set; }
    public string? SupplierName { get; set; }
    public double? DistanceKm { get; set; }
    public decimal? SupplierReliabilityScore { get; set; }

    // Simple rule-based flags for the demo — swap for a real risk-scoring
    // service later (this is where FraudPreventionLimit-style checks would
    // plug back in if that entity comes back).
    public List<string> RiskFlags { get; set; } = new();
}