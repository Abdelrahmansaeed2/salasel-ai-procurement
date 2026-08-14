using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Domain.Enums;
using Salasel.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Salasel.Application.Services;

public class OrderQueryService : IOrderQueryService
{
    private readonly IRepository<MasterOrder> _masterOrderRepository;

    public OrderQueryService(IRepository<MasterOrder> masterOrderRepository)
    {
        _masterOrderRepository = masterOrderRepository;
    }

    // Judgment call, since "active" isn't a real status: "active" here means
    // any order that hasn't been rejected (AI_Draft / Pending_Approval /
    // Manually_Approved all count). Adjust the predicate below if the intended
    // definition differs (e.g. only Manually_Approved).
    public async Task<OrderSummaryDto> GetOrderSummaryAsync(int merchantId)
    {
        var now = DateTime.UtcNow;
        var startOfThisMonth = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);
        var startOfLastMonth = startOfThisMonth.AddMonths(-1);

        var orders = await Task.FromResult(
            _masterOrderRepository.Query()
                .Where(o => o.MerchantId == merchantId
                            && o.Status != ApprovalStatus.Rejected
                            && o.OrderDate >= startOfLastMonth
                            && o.OrderDate < startOfThisMonth.AddMonths(1))
                .ToList());

        var thisMonthTotal = orders
            .Where(o => o.OrderDate >= startOfThisMonth)
            .Sum(o => o.TotalAmount);

        var lastMonthTotal = orders
            .Where(o => o.OrderDate >= startOfLastMonth && o.OrderDate < startOfThisMonth)
            .Sum(o => o.TotalAmount);

        decimal? percentChange = lastMonthTotal == 0
            ? null // no baseline to compare against
            : Math.Round((thisMonthTotal - lastMonthTotal) / lastMonthTotal * 100m, 2);

        return new OrderSummaryDto
        {
            ActiveTotal = thisMonthTotal,
            PercentChangeVsLastMonth = percentChange
        };
    }

    public async Task<OrderDetailDto> GetOrderByIdAsync(int orderId)
    {
        var order = await _masterOrderRepository.Query()
            .Include(o => o.SubOrders).ThenInclude(s => s.Supplier)
            .Include(o => o.SubOrders).ThenInclude(s => s.Product)
            .Include(o => o.VoiceLog).ThenInclude(v => v!.AIProcessing)
            .FirstOrDefaultAsync(o => o.Id == orderId);

        if (order == null)
        {
            throw new KeyNotFoundException($"Order {orderId} not found.");
        }

        OrderDetailAiInsightsDto? insights = null;
        if (order.VoiceLog?.AIProcessing != null)
        {
            insights = new OrderDetailAiInsightsDto
            {
                Language = "Arabic", // Stub as not captured in schema
                ProcessingTime = $"{Math.Round((order.VoiceLog.AIProcessing.ProcessingDurationMs ?? 0) / 1000.0, 1)}s",
                Confidence = $"{Math.Round(order.VoiceLog.AIProcessing.Confidence * 100)}%"
            };
        }

        var products = order.SubOrders.Select(s => new OrderDetailProductDto
        {
            SupplierName = s.Supplier?.CompanyName ?? "Unknown",
            ProductName = s.Product?.Name ?? "Unknown Product",
            RequestedQuantity = $"{s.Quantity} {(s.Product?.Unit ?? "")}".Trim(),
            DetectedQuantity = $"{s.Quantity} {(s.Product?.Unit ?? "")}".Trim(),
            UnitPrice = s.Quantity > 0 ? (s.SubTotalAmount / s.Quantity) : 0m
        }).ToList();

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

        return new OrderDetailDto
        {
            Id = order.Id,
            OrderNumber = $"#ORD-2024-{order.Id.ToString().PadLeft(5, '0')}", // Simple formatter
            TotalAmount = (double)order.TotalAmount,
            DeliveryFee = 0.0, // Stub
            Tax = 0.0,         // Stub
            OrderDate = order.OrderDate,
            Status = aggregatedStatus,
            Transcript = order.VoiceLog?.Transcript ?? string.Empty,
            AiInsights = insights,
            Products = products
        };
    }
}
