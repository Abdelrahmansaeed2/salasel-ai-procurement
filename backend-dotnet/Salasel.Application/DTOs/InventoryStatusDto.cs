namespace Salasel.Application.DTOs;

public class InventoryStatusDto
{
    public int MerchantID { get; set; }
    public List<InventoryItemDto> Items { get; set; } = new List<InventoryItemDto>();
}

public class InventoryItemDto
{
    public int InventoryID { get; set; }
    public string SKU { get; set; } = string.Empty;
    public int CurrentQuantity { get; set; }
    public int ReorderThreshold { get; set; }
    public bool NeedsReorder { get; set; }
    public DateTime LastUpdated { get; set; }
}
