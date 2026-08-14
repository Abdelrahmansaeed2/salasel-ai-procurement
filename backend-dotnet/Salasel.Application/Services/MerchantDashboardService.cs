using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Domain.Enums;
using Salasel.Domain.Interfaces;

namespace Salasel.Application.Services;

public class MerchantDashboardService : IMerchantDashboardService
{
    private readonly IRepository<MerchantInventory> _inventoryRepository;
    private readonly IRepository<MasterOrder> _masterOrderRepository;
    private readonly IRepository<SubOrder> _subOrderRepository;

    public MerchantDashboardService(
        IRepository<MerchantInventory> inventoryRepository,
        IRepository<MasterOrder> masterOrderRepository,
        IRepository<SubOrder> subOrderRepository)
    {
        _inventoryRepository = inventoryRepository;
        _masterOrderRepository = masterOrderRepository;
        _subOrderRepository = subOrderRepository;
    }

    public async Task<MerchantDashboardDto> GetDashboardAsync(int merchantId)
    {
        var lowStockCount = await _inventoryRepository.Query()
            .Where(i => i.MerchantID == merchantId && i.CurrentQty <= i.ReorderThreshold)
            .CountAsync();

        var pendingDeliveryCount = await _subOrderRepository.Query()
            .Where(s => s.MasterOrder.MerchantId == merchantId
                        && (s.Status == FulfillmentStatus.Accepted || s.Status == FulfillmentStatus.Shipped))
            .CountAsync();

        var pendingApprovalCount = await _masterOrderRepository.Query()
            .Where(o => o.MerchantId == merchantId
                        && (o.Status == ApprovalStatus.AI_Draft || o.Status == ApprovalStatus.Pending_Approval))
            .CountAsync();

        var recentOrders = await GetRecentOrdersAsync(merchantId, take: 10);

        return new MerchantDashboardDto
        {
            LowStockCount = lowStockCount,
            PendingDeliveryCount = pendingDeliveryCount,
            PendingApprovalCount = pendingApprovalCount,
            RecentOrders = recentOrders
        };
    }

    public async Task<List<RecentOrderDto>> GetRecentOrdersAsync(int merchantId, int take = 10)
    {
        var orders = await _masterOrderRepository.Query()
            .Where(o => o.MerchantId == merchantId)
            .Include(o => o.SubOrders).ThenInclude(s => s.Supplier)
            .Include(o => o.SubOrders).ThenInclude(s => s.Product)
            .Include(o => o.VoiceLog).ThenInclude(v => v!.AIProcessing)
            .OrderByDescending(o => o.OrderDate)
            .Take(take)
            .ToListAsync();

        return orders.Select(MapToRecentOrderDto).ToList();
    }

    private static RecentOrderDto MapToRecentOrderDto(MasterOrder order)
    {
        var supplierNames = order.SubOrders
            .Where(s => s.Supplier != null)
            .Select(s => s.Supplier!.CompanyName)
            .Distinct()
            .ToList();

        var hasOpenRfqLine = order.SubOrders.Any(s => s.Supplier == null);
        var supplier = supplierNames.Count switch
        {
            0 => hasOpenRfqLine ? "Awaiting bids" : "Unassigned",
            1 => supplierNames[0],
            _ => "Multiple Suppliers"
        };

        string aggregatedStatus = "Pending";
        if (order.Status == ApprovalStatus.Rejected) aggregatedStatus = "Rejected";
        else if (order.Status == ApprovalStatus.Manually_Approved)
        {
            if (order.SubOrders != null && order.SubOrders.Count > 0)
            {
                var allDelivered = order.SubOrders.All(s => s.Status == FulfillmentStatus.Delivered || s.Status == FulfillmentStatus.ReceiptConfirmed);
                var anyShipped = order.SubOrders.Any(s => s.Status == FulfillmentStatus.Shipped || s.Status == FulfillmentStatus.Delivered || s.Status == FulfillmentStatus.ReceiptConfirmed);
                var anyAccepted = order.SubOrders.Any(s => s.Status == FulfillmentStatus.Accepted);

                if (allDelivered) aggregatedStatus = "Completed";
                else if (anyShipped) aggregatedStatus = "Shipped";
                else if (anyAccepted) aggregatedStatus = "Accepted";
            }
        }

        return new RecentOrderDto
        {
            Id = order.Id,
            Supplier = supplier,
            Status = aggregatedStatus,
            ItemsSummary = BuildItemsSummary(order),
            OrderDate = order.OrderDate,
            TotalAmount = (double)order.TotalAmount
        };
    }

    // Voice-drafted orders aggregate multiple products into a single SubOrder
    // row with no per-line Product (see SubOrder.ProductId), so their item
    // breakdown has to come from the AI's raw parsed JSON instead. Manual /
    // reorder-created orders always have Product set per line, so those are
    // used directly.
    private static string BuildItemsSummary(MasterOrder order)
    {
        var linesWithProduct = order.SubOrders.Where(s => s.Product != null).ToList();
        if (linesWithProduct.Count > 0)
        {
            return string.Join(", ", linesWithProduct.Select(s => $"{s.Product!.Name} × {s.Quantity}"));
        }

        var parsedJson = order.VoiceLog?.AIProcessing?.ParsedJson;
        if (!string.IsNullOrWhiteSpace(parsedJson))
        {
            try
            {
                var parsed = JsonSerializer.Deserialize<VoiceParsedItemsJson>(parsedJson);
                if (parsed?.Items is { Count: > 0 })
                {
                    return string.Join(", ", parsed.Items.Select(i => $"{i.ProductName} × {i.Quantity}"));
                }
            }
            catch (JsonException)
            {
                // Fall through to empty summary below — malformed/legacy JSON shouldn't 500 the dashboard.
            }
        }

        return string.Empty;
    }

    // Mirrors the shape of Salasel.Infrastructure.Models.AiOrderResult, redeclared
    // here so the Application layer doesn't take a dependency on Infrastructure
    // just to deserialize AIProcessing.ParsedJson.
    private class VoiceParsedItemsJson
    {
        public List<VoiceParsedItemJson> Items { get; set; } = new();
    }

    private class VoiceParsedItemJson
    {
        public string ProductName { get; set; } = string.Empty;
        public int Quantity { get; set; }
    }

    // Judgment call: the mobile "recent orders" card wants a friendly label, not
    // the raw ApprovalStatus enum name. Adjust this mapping if product wants the
    // exact enum values surfaced instead.
    private static string MapStatusLabel(ApprovalStatus status) => status switch
    {
        ApprovalStatus.AI_Draft => "Pending",
        ApprovalStatus.Pending_Approval => "Pending",
        ApprovalStatus.Manually_Approved => "Approved",
        ApprovalStatus.Rejected => "Rejected",
        _ => status.ToString()
    };
}
