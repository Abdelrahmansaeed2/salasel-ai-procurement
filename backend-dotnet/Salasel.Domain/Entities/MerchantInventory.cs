namespace Salasel.Domain.Entities;

public class MerchantInventory
{
    public int InventoryID { get; set; }
    
    public int MerchantID { get; set; }
    public MerchantsProfile Merchant { get; set; } = null!;

    public string SKU { get; set; } = string.Empty;
    public int CurrentQuantity { get; set; }
    public int ReorderThreshold { get; set; }
    public DateTime LastUpdated { get; set; } = DateTime.UtcNow;
}
