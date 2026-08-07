namespace Salasel.Application.DTOs;

// GET /api/v1/merchants/me/dashboard
public class MerchantDashboardDto
{
    public int LowStockCount { get; set; }
    public int PendingDeliveryCount { get; set; }
    public int PendingApprovalCount { get; set; }
    public List<RecentOrderDto> RecentOrders { get; set; } = new();
}

// Also used standalone by GET /api/v1/merchants/me/recent-orders
public class RecentOrderDto
{
    public int Id { get; set; }

    // First supplier on the order, or "Multiple Suppliers" when the order
    // was split across more than one (see MerchantDashboardService).
    public string Supplier { get; set; } = string.Empty;

    // Friendly label, not the raw enum name — see MapStatusLabel().
    public string Status { get; set; } = string.Empty;

    // Best-effort "ProductName × Qty, ProductName × Qty" built from the
    // order's SubOrders (each now carries a ProductId — see SubOrder.cs).
    public string ItemsSummary { get; set; } = string.Empty;
}

// GET /api/v1/orders/summary?merchantId=
public class OrderSummaryDto
{
    // Sum of TotalAmount for orders in an "active" (non-rejected) state,
    // for the current calendar month.
    public decimal ActiveTotal { get; set; }

    // (thisMonthTotal - lastMonthTotal) / lastMonthTotal * 100.
    // Null when there is no data for last month to compare against.
    public decimal? PercentChangeVsLastMonth { get; set; }
}
