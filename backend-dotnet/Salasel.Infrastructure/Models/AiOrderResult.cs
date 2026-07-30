namespace Salasel.Infrastructure.Models;

public class AiOrderItem
{
    public string ProductName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal Price { get; set; }
}

public class AiOrderResult
{
    public int MerchantId { get; set; }
    public List<AiOrderItem> Items { get; set; } = new();
}
