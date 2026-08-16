namespace Salasel.Domain.Entities;

public class MerchantInventory
{
    public int InventoryID { get; set; }

    public int MerchantID { get; set; }
    public MerchantsProfile Merchant { get; set; } = null!;

    public int? ProductId { get; set; }
    public Product? Product { get; set; }

    // External / Custom Products
    public string? CustomProductName { get; set; }
    public string? CustomCategory { get; set; }
    public string? CustomBarcode { get; set; }
    public decimal CostPrice { get; set; }

    public decimal CurrentQty { get; set; }
    public decimal ReorderThreshold { get; set; }  // AI triggers order when CurrentQty <= this
    public DateTime LastUpdated { get; set; } = DateTime.UtcNow;

    // Set by POST /api/v1/inventory/alerts/{id}/dismiss. The alert stays hidden as
    // long as CurrentQty hasn't dropped further since it was dismissed; if stock
    // drops again after dismissal, the alert reappears.
    public DateTime? LowStockAlertDismissedAt { get; set; }
    public int? LowStockAlertDismissedAtQty { get; set; }
}
