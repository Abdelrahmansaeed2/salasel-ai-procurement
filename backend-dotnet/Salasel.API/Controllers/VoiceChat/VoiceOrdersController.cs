using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Salasel.Domain.Entities;
using Salasel.Domain.Enums;
using Salasel.Infrastructure.Data;
using Salasel.Infrastructure.Models;
using Salasel.Infrastructure.Services;

namespace Salasel.API.Controllers.VoiceChat;


[ApiController]
[Route("api/v1/voice-orders")]
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
            await _notifications.NotifySupplierAsync(supplierId.Value, "NewOrderReceived", payload);

        await _notifications.NotifyAllAdminsAsync("NewOrderReceived", payload);

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
            so.AcceptedAt = DateTime.UtcNow;
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

    // ───────────────────────── Draft item editing ─────────────────────────
    // The AI draft's line items live inside AIProcessing.ParsedJson (there's
    // only ever one SubOrder per draft today, aggregating quantity/subtotal
    // across all lines) — so "editing an item" means mutating that JSON, then
    // recomputing MasterOrder.TotalAmount and the SubOrder aggregate to match.

    /// <summary>Add a product line to a draft.</summary>
    [HttpPost("{id:int}/items")]
    public async Task<IActionResult> AddItem(int id, [FromBody] AddDraftItemDto request)
    {
        var order = await LoadOrder(id);
        if (order is null) return NotFound(new { error = "Order not found." });

        var (ok, error, aiResult) = TryGetEditableAiResult(order);
        if (!ok) return BadRequest(new { error });

        aiResult!.Items.Add(new AiOrderItem
        {
            ProductName = request.ProductName,
            Quantity = request.Quantity,
            Price = request.Price
        });

        var payload = await RecalculateAndSaveAsync(order, aiResult);
        return Ok(new { message = "Item added.", order = payload });
    }

    /// <summary>Update an existing draft line (itemId travels in the body).</summary>
    [HttpPut("{id:int}/items")]
    public async Task<IActionResult> UpdateItem(int id, [FromBody] UpdateDraftItemDto request)
    {
        var order = await LoadOrder(id);
        if (order is null) return NotFound(new { error = "Order not found." });

        var (ok, error, aiResult) = TryGetEditableAiResult(order);
        if (!ok) return BadRequest(new { error });

        var item = aiResult!.Items.FirstOrDefault(i => i.Id == request.ItemId);
        if (item is null) return NotFound(new { error = $"Item {request.ItemId} not found on this order." });

        item.ProductName = request.ProductName;
        item.Quantity = request.Quantity;
        item.Price = request.Price;

        var payload = await RecalculateAndSaveAsync(order, aiResult);
        return Ok(new { message = "Item updated.", order = payload });
    }

    /// <summary>Remove a line from a draft.</summary>
    [HttpDelete("{id:int}/items/{itemId}")]
    public async Task<IActionResult> RemoveItem(int id, string itemId)
    {
        var order = await LoadOrder(id);
        if (order is null) return NotFound(new { error = "Order not found." });

        var (ok, error, aiResult) = TryGetEditableAiResult(order);
        if (!ok) return BadRequest(new { error });

        var item = aiResult!.Items.FirstOrDefault(i => i.Id == itemId);
        if (item is null) return NotFound(new { error = $"Item {itemId} not found on this order." });

        if (aiResult.Items.Count == 1)
            return BadRequest(new { error = "Cannot remove the last item — cancel the draft instead." });

        aiResult.Items.Remove(item);

        var payload = await RecalculateAndSaveAsync(order, aiResult);
        return Ok(new { message = "Item removed.", order = payload });
    }

    /// <summary>Confidence, distance, and simple risk flags for the draft's supplier card.</summary>
    [HttpGet("{id:int}/ai-insights")]
    public async Task<IActionResult> GetAiInsights(int id)
    {
        var order = await LoadOrder(id);
        if (order is null) return NotFound(new { error = "Order not found." });

        var aiProcessing = order.VoiceLog?.AIProcessing;
        var sub = order.SubOrders.FirstOrDefault();

        double? distanceKm = null;
        if (order.Merchant != null && sub?.Supplier != null)
        {
            distanceKm = GeoHelper.DistanceKm(
                (double)order.Merchant.LocationLat,
                (double)order.Merchant.LocationLng,
                (double)sub.Supplier.LocationLat,
                (double)sub.Supplier.LocationLng);
        }

        var confidence = aiProcessing?.Confidence ?? 0m;
        var flags = new List<string>();

        if (aiProcessing is null)
            flags.Add("AI processing has not completed yet for this order.");
        if (confidence > 0 && confidence < 0.75m)
            flags.Add("Low AI confidence — please review items carefully before confirming.");
        if (sub?.Supplier is null)
            flags.Add("No supplier has been assigned to this order yet.");
        else if (sub.Supplier.ReliabilityScore < 60m)
            flags.Add("Assigned supplier has a below-average reliability score.");
        if (order.TotalAmount >= 5000m)
            flags.Add("Order value is unusually high — double-check quantities before confirming.");

        var insights = new AiInsightsDto
        {
            OrderId = order.Id,
            Confidence = confidence,
            ModelUsed = aiProcessing?.ModelUsed ?? "N/A",
            SupplierId = sub?.SupplierId,
            SupplierName = sub?.Supplier?.CompanyName,
            DistanceKm = distanceKm.HasValue ? Math.Round(distanceKm.Value, 2) : null,
            SupplierReliabilityScore = sub?.Supplier?.ReliabilityScore,
            RiskFlags = flags
        };

        return Ok(insights);
    }

    // ───────────────────── Tracking, delivery, payment ─────────────────────
    // Deliberately kept on the same /api/voice-orders resource rather than a
    // separate /api/v1/orders controller — this project only has one order
    // pipeline, and splitting it in two here would recreate the exact
    // duplicate-system problem flagged earlier for the voice endpoints.

    /// <summary>Delivery timeline for the order's single sub-order.</summary>
    [HttpGet("{id:int}/tracking")]
    public async Task<IActionResult> GetTracking(int id)
    {
        var order = await LoadOrder(id);
        if (order is null) return NotFound(new { error = "Order not found." });

        var sub = order.SubOrders.FirstOrDefault();

        var timeline = new List<TrackingStepDto>
        {
            new() { Step = "Confirmed", Completed = order.Status != ApprovalStatus.AI_Draft, Timestamp = order.Status != ApprovalStatus.AI_Draft ? order.UpdatedAt : null },
            new() { Step = "Approved", Completed = sub?.AcceptedAt != null, Timestamp = sub?.AcceptedAt },
            new() { Step = "Shipped", Completed = sub?.ShippedAt != null, Timestamp = sub?.ShippedAt },
            new() { Step = "Delivered", Completed = sub?.DeliveredAt != null, Timestamp = sub?.DeliveredAt },
            new() { Step = "ReceiptConfirmed", Completed = sub?.ReceiptConfirmedAt != null, Timestamp = sub?.ReceiptConfirmedAt }
        };

        return Ok(new TrackingDto
        {
            OrderId = order.Id,
            CurrentStatus = sub?.Status.ToString() ?? order.Status.ToString(),
            Timeline = timeline
        });
    }

    /// <summary>Supplier marks the order as shipped. Requires checkout to have happened first.</summary>
    [HttpPut("{id:int}/ship")]
    public async Task<IActionResult> Ship(int id)
    {
        var order = await LoadOrder(id);
        if (order is null) return NotFound(new { error = "Order not found." });

        var sub = order.SubOrders.FirstOrDefault();
        if (sub is null || sub.Status != FulfillmentStatus.Accepted)
            return BadRequest(new { error = $"Only an Accepted order can be shipped (current: {sub?.Status.ToString() ?? "none"})." });

        if (order.PaymentMethod is null)
            return BadRequest(new { error = "Checkout has not been completed — call POST .../payment first." });

        sub.Status = FulfillmentStatus.Shipped;
        sub.ShippedAt = DateTime.UtcNow;
        sub.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        var payload = OrderMapper.MapWithParsedItems(order, order.VoiceLog?.AIProcessing?.ParsedJson);
        await _notifications.NotifyMerchantAsync(order.MerchantId, "OrderShipped", payload);

        return Ok(new { message = "Order marked as shipped.", order = payload });
    }

    /// <summary>Supplier marks the order as delivered. Cash-on-delivery orders are marked Paid here.</summary>
    [HttpPut("{id:int}/deliver")]
    public async Task<IActionResult> Deliver(int id)
    {
        var order = await LoadOrder(id);
        if (order is null) return NotFound(new { error = "Order not found." });

        var sub = order.SubOrders.FirstOrDefault();
        if (sub is null || sub.Status != FulfillmentStatus.Shipped)
            return BadRequest(new { error = $"Only a Shipped order can be delivered (current: {sub?.Status.ToString() ?? "none"})." });

        sub.Status = FulfillmentStatus.Delivered;
        sub.DeliveredAt = DateTime.UtcNow;
        sub.UpdatedAt = DateTime.UtcNow;

        // Cash is collected at the door, so COD orders settle on delivery.
        if (order.PaymentMethod == PaymentMethod.CashOnDelivery && order.PaymentStatus != PaymentStatus.Paid)
        {
            order.PaymentStatus = PaymentStatus.Paid;
            order.PaidAt = DateTime.UtcNow;
            order.PaymentReference = $"COD-{order.Id}-{DateTime.UtcNow:yyyyMMddHHmmss}";
        }

        await _db.SaveChangesAsync();

        var payload = OrderMapper.MapWithParsedItems(order, order.VoiceLog?.AIProcessing?.ParsedJson);
        await _notifications.NotifyMerchantAsync(order.MerchantId, "OrderDelivered", payload);

        return Ok(new { message = "Order marked as delivered.", order = payload });
    }

    /// <summary>Merchant confirms the goods physically arrived, closing out the order.</summary>
    [HttpPost("{id:int}/confirm-receipt")]
    public async Task<IActionResult> ConfirmReceipt(int id)
    {
        var order = await LoadOrder(id);
        if (order is null) return NotFound(new { error = "Order not found." });

        var sub = order.SubOrders.FirstOrDefault();
        if (sub is null || sub.Status != FulfillmentStatus.Delivered)
            return BadRequest(new { error = $"Only a Delivered order can have its receipt confirmed (current: {sub?.Status.ToString() ?? "none"})." });

        sub.Status = FulfillmentStatus.ReceiptConfirmed;
        sub.ReceiptConfirmedAt = DateTime.UtcNow;
        sub.UpdatedAt = DateTime.UtcNow;

        order.Status = ApprovalStatus.Completed;
        order.UpdatedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync();

        var payload = OrderMapper.MapWithParsedItems(order, order.VoiceLog?.AIProcessing?.ParsedJson);
        await _notifications.NotifySupplierAsync(sub.SupplierId ?? 0, "ReceiptConfirmed", payload);

        return Ok(new { message = "Receipt confirmed. Order complete.", order = payload });
    }

    /// <summary>Supplier assigns a driver to an accepted/shipped order.</summary>
    [HttpPost("{id:int}/assign-driver")]
    public async Task<IActionResult> AssignDriver(int id, [FromBody] AssignDriverDto request)
    {
        var order = await LoadOrder(id);
        if (order is null) return NotFound(new { error = "Order not found." });

        var sub = order.SubOrders.FirstOrDefault();
        if (sub is null || (sub.Status != FulfillmentStatus.Accepted && sub.Status != FulfillmentStatus.Shipped))
            return BadRequest(new { error = $"A driver can only be assigned to an Accepted or Shipped order (current: {sub?.Status.ToString() ?? "none"})." });

        sub.DriverName = request.DriverName;
        sub.DriverPhone = request.DriverPhone;
        sub.UpdatedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync();

        return Ok(new { message = "Driver assigned.", sub.DriverName, sub.DriverPhone });
    }

    /// <summary>Merchant checkout: choose a payment method to finalize the financial commitment.</summary>
    [HttpPost("{id:int}/payment")]
    public async Task<IActionResult> MakePayment(int id, [FromBody] MakePaymentDto request)
    {
        var order = await LoadOrder(id);
        if (order is null) return NotFound(new { error = "Order not found." });

        if (order.Status != ApprovalStatus.Manually_Approved)
            return BadRequest(new { error = $"Checkout is only available once the order is Approved (current: {order.Status})." });

        if (order.PaymentMethod is not null)
            return BadRequest(new { error = "Payment has already been made for this order." });

        order.PaymentMethod = request.PaymentMethod;

        // Bank transfer / credit card are simulated as an instant successful
        // charge for the demo — there's no real payment gateway wired in.
        // Cash on delivery settles later, in Deliver() above.
        if (request.PaymentMethod == PaymentMethod.CashOnDelivery)
        {
            order.PaymentStatus = PaymentStatus.Pending;
        }
        else
        {
            order.PaymentStatus = PaymentStatus.Paid;
            order.PaidAt = DateTime.UtcNow;
            order.PaymentReference = $"SIM-{request.PaymentMethod}-{order.Id}-{DateTime.UtcNow:yyyyMMddHHmmss}";
        }

        order.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return Ok(new PaymentStatusDto
        {
            OrderId = order.Id,
            PaymentMethod = order.PaymentMethod?.ToString(),
            PaymentStatus = order.PaymentStatus.ToString(),
            Amount = order.TotalAmount,
            PaidAt = order.PaidAt,
            PaymentReference = order.PaymentReference
        });
    }

    [HttpGet("{id:int}/payment-status")]
    public async Task<IActionResult> GetPaymentStatus(int id)
    {
        var order = await LoadOrder(id);
        if (order is null) return NotFound(new { error = "Order not found." });

        return Ok(new PaymentStatusDto
        {
            OrderId = order.Id,
            PaymentMethod = order.PaymentMethod?.ToString(),
            PaymentStatus = order.PaymentStatus.ToString(),
            Amount = order.TotalAmount,
            PaidAt = order.PaidAt,
            PaymentReference = order.PaymentReference
        });
    }

    // ───────────────────────────── Helpers ─────────────────────────────────

    private Task<Domain.Entities.MasterOrder?> LoadOrder(int id) =>
        _db.MasterOrders
            .Include(o => o.Merchant)
            .Include(o => o.SubOrders).ThenInclude(s => s.Supplier)
            .Include(o => o.VoiceLog)!.ThenInclude(v => v!.AIProcessing)
            .FirstOrDefaultAsync(o => o.Id == id);

    private static (bool ok, string? error, AiOrderResult? result) TryGetEditableAiResult(MasterOrder order)
    {
        if (order.Status != ApprovalStatus.AI_Draft)
            return (false, $"Items can only be edited while the order is a Draft (current: {order.Status}).", null);

        var parsedJson = order.VoiceLog?.AIProcessing?.ParsedJson;
        if (string.IsNullOrWhiteSpace(parsedJson))
            return (false, "This order has no AI-parsed items yet.", null);

        AiOrderResult? result;
        try
        {
            result = JsonSerializer.Deserialize<AiOrderResult>(parsedJson, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });
        }
        catch (JsonException)
        {
            return (false, "Stored AI result is malformed and cannot be edited.", null);
        }

        if (result is null)
            return (false, "Stored AI result is empty and cannot be edited.", null);

        return (true, null, result);
    }

    private async Task<object> RecalculateAndSaveAsync(MasterOrder order, AiOrderResult aiResult)
    {
        var aiProcessing = order.VoiceLog!.AIProcessing!;
        aiProcessing.ParsedJson = JsonSerializer.Serialize(aiResult);

        var total = aiResult.Items.Sum(i => i.Quantity * i.Price);
        var totalQty = aiResult.Items.Sum(i => i.Quantity);

        order.TotalAmount = total;
        order.UpdatedAt = DateTime.UtcNow;

        // Single aggregate SubOrder today (see class-level comment) — keep it
        // in sync with the edited item list.
        var sub = order.SubOrders.FirstOrDefault();
        if (sub != null)
        {
            sub.Quantity = totalQty;
            sub.SubTotalAmount = total;
            sub.UpdatedAt = DateTime.UtcNow;
        }

        await _db.SaveChangesAsync();

        return OrderMapper.MapWithParsedItems(order, aiProcessing.ParsedJson);
    }
}