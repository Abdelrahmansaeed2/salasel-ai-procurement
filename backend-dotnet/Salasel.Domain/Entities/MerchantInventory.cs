namespace Salasel.Domain.Entities;

public class MerchantInventory
{
    public int InventoryID { get; set; }

    public int MerchantID { get; set; }
    public MerchantsProfile Merchant { get; set; } = null!;

    public int ProductId { get; set; }
    public Product Product { get; set; } = null!;

    public int CurrentQty { get; set; }
    public int ReorderThreshold { get; set; }  // AI triggers order when CurrentQty <= this
    public DateTime LastUpdated { get; set; } = DateTime.UtcNow;
}
