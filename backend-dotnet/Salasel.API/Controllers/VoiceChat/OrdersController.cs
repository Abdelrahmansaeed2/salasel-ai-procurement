using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Salasel.Domain.Enums;
using Salasel.Infrastructure.Data;
using Salasel.Infrastructure.Services;

namespace Salasel.API.Controllers.VoiceChat;


[ApiController]
[Route("api/voice-orders")]
public class VoiceOrdersController : ControllerBase
{
    private readonly SalaselDbContext _db;
    private readonly INotificationService _notifications;
    private readonly ILogger<VoiceOrdersController> _logger;

    public VoiceOrdersController(
        SalaselDbContext db,
        INotificationService notifications,
        ILogger<VoiceOrdersController> logger)
    {
        _db = db;
        _notifications = notifications;
        _logger = logger;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(
        [FromQuery] int? merchantId,
        [FromQuery] int? supplierId,
        [FromQuery] string? status)
    {
        var q = _db.MasterOrders
            .Include(o => o.Merchant)
            .Include(o => o.SubOrders).ThenInclude(s => s.Supplier)
            .Include(o => o.VoiceLog)!.ThenInclude(v => v!.AIProcessing)
            .AsQueryable();

        if (merchantId.HasValue)
            q = q.Where(o => o.MerchantId == merchantId);

        if (supplierId.HasValue)
            q = q.Where(o => o.SubOrders.Any(s => s.SupplierId == supplierId));

        var list = await q.OrderByDescending(o => o.OrderDate).ToListAsync();

        // Optional status filter (mapped demo names)
        if (!string.IsNullOrEmpty(status))
        {
            list = list.Where(o =>
            {
                var mapped = OrderMapper.MapWithParsedItems(o, o.VoiceLog?.AIProcessing?.ParsedJson);
                var prop = mapped.GetType().GetProperty("status");
                var val = prop?.GetValue(mapped)?.ToString();
                return string.Equals(val, status, StringComparison.OrdinalIgnoreCase);
            }).ToList();
        }

        var result = list.Select(o =>
            OrderMapper.MapWithParsedItems(o, o.VoiceLog?.AIProcessing?.ParsedJson));

        return Ok(result);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var order = await LoadOrder(id);
        if (order is null) return NotFound();
        return Ok(OrderMapper.MapWithParsedItems(order, order.VoiceLog?.AIProcessing?.ParsedJson));
    }

    /// <summary>Merchant confirms a draft → notifies supplier.</summary>
    [HttpPut("{id:int}/confirm")]
    public async Task<IActionResult> Confirm(int id)
    {
        var order = await LoadOrder(id);
        if (order is null) return NotFound(new { error = "Order not found." });
        if (order.Status != ApprovalStatus.AI_Draft)
            return BadRequest(new { error = $"Only Draft orders can be confirmed (current: {order.Status})." });

        order.Status = ApprovalStatus.Pending_Approval;
        order.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        var payload = OrderMapper.MapWithParsedItems(order, order.VoiceLog?.AIProcessing?.ParsedJson);
        var supplierId = order.SubOrders.FirstOrDefault()?.SupplierId;

        if (supplierId.HasValue)
            await _notifications.NotifySupplierAsync(supplierId.Value, "NewOrder", payload);

        await _notifications.NotifyMerchantAsync(order.MerchantId, "OrderConfirmed", payload);

        _logger.LogInformation("Order {OrderId} confirmed. Supplier {SupplierId} notified.", order.Id, supplierId);

        return Ok(new { message = "Order confirmed. Waiting for supplier approval.", order = payload });
    }

    /// <summary>Merchant cancels a draft.</summary>
    [HttpPut("{id:int}/cancel")]
    public async Task<IActionResult> Cancel(int id)
    {
        var order = await LoadOrder(id);
        if (order is null) return NotFound(new { error = "Order not found." });
        if (order.Status != ApprovalStatus.AI_Draft)
            return BadRequest(new { error = $"Only Draft orders can be cancelled (current: {order.Status})." });

        order.Status = ApprovalStatus.Rejected;
        order.UpdatedAt = DateTime.UtcNow;
        foreach (var so in order.SubOrders)
        {
            so.Status = FulfillmentStatus.Cancelled;
            so.UpdatedAt = DateTime.UtcNow;
        }
        await _db.SaveChangesAsync();

        var payload = OrderMapper.MapWithParsedItems(order, order.VoiceLog?.AIProcessing?.ParsedJson);
        await _notifications.NotifyMerchantAsync(order.MerchantId, "OrderCancelled", payload);

        return Ok(new { message = "Draft order cancelled.", order = payload });
    }

    /// <summary>Supplier approves a confirmed order.</summary>
    [HttpPut("{id:int}/approve")]
    public async Task<IActionResult> Approve(int id)
    {
        var order = await LoadOrder(id);
        if (order is null) return NotFound(new { error = "Order not found." });
        if (order.Status != ApprovalStatus.Pending_Approval)
            return BadRequest(new { error = $"Only Confirmed orders can be approved (current: {order.Status})." });

        order.Status = ApprovalStatus.Manually_Approved;
        order.UpdatedAt = DateTime.UtcNow;
        foreach (var so in order.SubOrders)
        {
            so.Status = FulfillmentStatus.Accepted;
            so.UpdatedAt = DateTime.UtcNow;
        }
        await _db.SaveChangesAsync();

        var payload = OrderMapper.MapWithParsedItems(order, order.VoiceLog?.AIProcessing?.ParsedJson);
        var supplierId = order.SubOrders.FirstOrDefault()?.SupplierId ?? 0;

        await _notifications.NotifyMerchantAsync(order.MerchantId, "OrderAccepted", payload);
        if (supplierId > 0)
            await _notifications.NotifySupplierAsync(supplierId, "OrderAccepted", payload);

        _logger.LogInformation("Order {OrderId} accepted by supplier {SupplierId}.", order.Id, supplierId);

        return Ok(new { message = "Order approved. Merchant has been notified.", order = payload });
    }

    /// <summary>Supplier declines a confirmed order.</summary>
    [HttpPut("{id:int}/decline")]
    public async Task<IActionResult> Decline(int id)
    {
        var order = await LoadOrder(id);
        if (order is null) return NotFound(new { error = "Order not found." });
        if (order.Status != ApprovalStatus.Pending_Approval)
            return BadRequest(new { error = $"Only Confirmed orders can be declined (current: {order.Status})." });

        order.Status = ApprovalStatus.Rejected;
        order.UpdatedAt = DateTime.UtcNow;
        foreach (var so in order.SubOrders)
        {
            so.Status = FulfillmentStatus.Cancelled;
            so.UpdatedAt = DateTime.UtcNow;
        }
        await _db.SaveChangesAsync();

        var payload = OrderMapper.MapWithParsedItems(order, order.VoiceLog?.AIProcessing?.ParsedJson);
        var supplierId = order.SubOrders.FirstOrDefault()?.SupplierId ?? 0;

        await _notifications.NotifyMerchantAsync(order.MerchantId, "OrderDeclined", payload);
        if (supplierId > 0)
            await _notifications.NotifySupplierAsync(supplierId, "OrderDeclined", payload);

        _logger.LogInformation("Order {OrderId} declined by supplier {SupplierId}.", order.Id, supplierId);

        return Ok(new { message = "Order declined. Merchant has been notified.", order = payload });
    }

    private Task<Domain.Entities.MasterOrder?> LoadOrder(int id) =>
        _db.MasterOrders
            .Include(o => o.Merchant)
            .Include(o => o.SubOrders).ThenInclude(s => s.Supplier)
            .Include(o => o.VoiceLog)!.ThenInclude(v => v!.AIProcessing)
            .FirstOrDefaultAsync(o => o.Id == id);
}
