using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Domain.Enums;
using Salasel.Domain.Interfaces;

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
}
