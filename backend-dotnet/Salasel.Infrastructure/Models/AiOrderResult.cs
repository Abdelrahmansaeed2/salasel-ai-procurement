namespace Salasel.Infrastructure.Models;

public class AiOrderItem
{
    public string Id { get; set; } = Guid.NewGuid().ToString("N");
    public int? ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal Price { get; set; }
}

public class AiOrderResult
{
    public int MerchantId { get; set; }
    public List<AiOrderItem> Items { get; set; } = new();

    // Added when wired to the real ai_service (POST /api/v1/voice/order/{merchant_id}).
    // TotalOrderCost is the AI-computed order total (sum of splits); PreferredSupplierId
    // is the dominant supplier from the splits (fallback: nearest-supplier routing);
    // Unresolved carries product terms the AI could not map to a supplier/product.
    public decimal TotalOrderCost { get; set; }
    public int? PreferredSupplierId { get; set; }
    public List<string> Unresolved { get; set; } = new();
    public string? ModelUsed { get; set; }
}
