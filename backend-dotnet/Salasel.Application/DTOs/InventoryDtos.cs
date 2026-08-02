namespace Salasel.Application.DTOs;

// Shared shape for list items and item detail.
public class InventoryItemDetailDto
{
    public int InventoryID { get; set; }
    public int MerchantID { get; set; }

    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string SKU { get; set; } = string.Empty;
    public string Unit { get; set; } = string.Empty;
    public string? ImageUrl { get; set; }

    public int CategoryId { get; set; }
    public string CategoryName { get; set; } = string.Empty;

    public int CurrentQty { get; set; }
    public int ReorderThreshold { get; set; }

    // "Out" (0), "Low" (<= ReorderThreshold), "Ok" (above threshold)
    public string Status { get; set; } = string.Empty;

    public DateTime LastUpdated { get; set; }
}

// GET /api/v1/inventory?merchantId=&category=&q=&status=
public class InventoryListResultDto
{
    public int MerchantID { get; set; }
    public List<InventoryItemDetailDto> Items { get; set; } = new();
}

// PUT /api/v1/inventory/{id}
public class UpdateInventoryItemDto
{
    public int CurrentQty { get; set; }
    public int ReorderThreshold { get; set; }
}

// PUT /api/v1/inventory/{id}/quantity
public class UpdateInventoryQuantityDto
{
    public int Quantity { get; set; }
}

// POST /api/v1/inventory/{id}/reorder
public class ReorderRequestDto
{
    // Optional override. When omitted, defaults to enough to bring stock
    // back to 2x the reorder threshold (see InventoryService.ReorderAsync).
    public int? Quantity { get; set; }
}

public class ReorderResultDto
{
    public int MasterOrderId { get; set; }
    public int SupplierId { get; set; }
    public string SupplierName { get; set; } = string.Empty;
    public int QuantityOrdered { get; set; }
    public decimal SubTotalCost { get; set; }
}

// GET /api/v1/inventory/alerts?merchantId=
public class InventoryAlertDto
{
    public int InventoryID { get; set; }
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string SKU { get; set; } = string.Empty;
    public int CurrentQty { get; set; }
    public int ReorderThreshold { get; set; }

    // NOTE: real "runs out in N days" needs a consumption-history table
    // (daily usage over time), which doesn't exist yet in this schema.
    // Left null here rather than faking a number — wire this up once
    // usage tracking exists. See InventoryService.GetAlertsAsync.
    public int? EstimatedDaysUntilStockOut { get; set; }
}
