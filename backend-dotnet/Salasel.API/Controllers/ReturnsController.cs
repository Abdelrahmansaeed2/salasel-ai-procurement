using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Salasel.Domain.Entities;
using Salasel.Infrastructure.Data;
using Salasel.Infrastructure.Services;
using Salasel.Application.Interfaces;
using System.Security.Claims;
using System.Text.Json;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/returns")]
[Authorize]
public class ReturnsController : ControllerBase
{
    private readonly SalaselDbContext _db;
    private readonly INotificationService _notifications;
    private readonly IPaymentService _stripe;
    private readonly ILogger<ReturnsController> _logger;

    public ReturnsController(
        SalaselDbContext db,
        INotificationService notifications,
        IPaymentService stripe,
        ILogger<ReturnsController> logger)
    {
        _db = db;
        _notifications = notifications;
        _stripe = stripe;
        _logger = logger;
    }

    private int GetCurrentUserId() =>
        int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "0");
    private string GetCurrentUserRole() =>
        User.FindFirstValue(ClaimTypes.Role) ?? "";

    [HttpPost]
    public async Task<IActionResult> CreateReturnRequest([FromBody] ReturnRequestDto dto)
    {
        var userId = GetCurrentUserId();
        if (GetCurrentUserRole() != "Merchant")
            return Forbid();

        var shop = await _db.MerchantsProfiles.FirstOrDefaultAsync(m => m.OwnerUserId == userId);
        if (shop == null) return NotFound("Merchant profile not found.");
        var merchantId = shop.MerchantID;

        var order = await _db.MasterOrders
            .Include(o => o.SubOrders)
            .FirstOrDefaultAsync(o => o.Id == dto.MasterOrderId && o.MerchantId == merchantId);

        if (order == null)
            return NotFound("Order not found or does not belong to you.");

        // Check 48-hour delivery window
        var subOrder = order.SubOrders.FirstOrDefault();
        if (subOrder?.Status != Salasel.Domain.Enums.FulfillmentStatus.Delivered && 
            subOrder?.Status != Salasel.Domain.Enums.FulfillmentStatus.ReceiptConfirmed)
            return BadRequest("Only delivered orders can be returned.");

        if (subOrder.UpdatedAt.HasValue && (DateTime.UtcNow - subOrder.UpdatedAt.Value).TotalHours > 48)
            return BadRequest("Return window (48 hours) has expired.");

        var ret = new ReturnRequest
        {
            MasterOrderId = dto.MasterOrderId,
            MerchantId = merchantId,
            SupplierId = subOrder.SupplierId,
            Reason = dto.Reason,
            PhotosJson = JsonSerializer.Serialize(dto.Photos),
            ItemsJson = JsonSerializer.Serialize(dto.Items),
            RequestedAmount = dto.RequestedAmount,
            Status = ReturnStatus.Pending
        };

        _db.ReturnRequests.Add(ret);
        await _db.SaveChangesAsync();

        if (ret.SupplierId.HasValue)
        {
            await _notifications.NotifySupplierAsync(ret.SupplierId.Value, "NewReturnRequest", new { ret.Id, ret.MasterOrderId });
        }

        return Ok(ret);
    }

    [HttpGet]
    public async Task<IActionResult> GetReturns()
    {
        var userId = GetCurrentUserId();
        var role = GetCurrentUserRole();

        var query = _db.ReturnRequests
            .Include(r => r.MasterOrder)
            .AsQueryable();

        if (role == "Merchant") 
        {
            var shop = await _db.MerchantsProfiles.FirstOrDefaultAsync(m => m.OwnerUserId == userId);
            if (shop != null) query = query.Where(r => r.MerchantId == shop.MerchantID);
            else query = query.Where(r => false); // Return empty if no profile
        }
        else if (role == "Supplier") 
        {
            var supplier = await _db.SupplierProfiles.FirstOrDefaultAsync(s => s.OwnerUserId == userId);
            if (supplier != null) query = query.Where(r => r.SupplierId == supplier.SupplierID);
            else query = query.Where(r => false); // Return empty if no profile
        }
        
        var list = await query.OrderByDescending(r => r.CreatedAt).ToListAsync();
        return Ok(list);
    }

    [HttpPut("{id:int}/approve")]
    public async Task<IActionResult> ApproveReturn(int id, [FromBody] ApproveReturnDto dto)
    {
        if (GetCurrentUserRole() != "Supplier") return Forbid();
        var userId = GetCurrentUserId();
        var supplier = await _db.SupplierProfiles.FirstOrDefaultAsync(s => s.OwnerUserId == userId);
        if (supplier == null) return NotFound("Supplier profile not found");
        var supplierId = supplier.SupplierID;

        var ret = await _db.ReturnRequests.FirstOrDefaultAsync(r => r.Id == id && r.SupplierId == supplierId);
        if (ret == null) return NotFound();
        if (ret.Status != ReturnStatus.Pending) return BadRequest("Only pending returns can be approved.");

        ret.Status = ReturnStatus.Approved;
        ret.ApprovedAmount = dto.ApprovedAmount;
        ret.UpdatedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync();

        await _notifications.NotifyMerchantAsync(ret.MerchantId, "ReturnApproved", new { 
            ret.Id, 
            Message = "Supplier approved return. A driver will be sent to pick up the items." 
        });

        return Ok(ret);
    }

    [HttpPut("{id:int}/reject")]
    public async Task<IActionResult> RejectReturn(int id, [FromBody] RejectReturnDto dto)
    {
        if (GetCurrentUserRole() != "Supplier") return Forbid();
        var userId = GetCurrentUserId();
        var supplier = await _db.SupplierProfiles.FirstOrDefaultAsync(s => s.OwnerUserId == userId);
        if (supplier == null) return NotFound("Supplier profile not found");
        var supplierId = supplier.SupplierID;

        var ret = await _db.ReturnRequests.FirstOrDefaultAsync(r => r.Id == id && r.SupplierId == supplierId);
        if (ret == null) return NotFound();
        
        ret.Status = ReturnStatus.Rejected;
        ret.UpdatedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync();
        await _notifications.NotifyMerchantAsync(ret.MerchantId, "ReturnRejected", new { ret.Id, Reason = dto.Reason });

        return Ok(ret);
    }

    [HttpPut("{id:int}/confirm-receipt")]
    public async Task<IActionResult> ConfirmReceiptAndRefund(int id)
    {
        if (GetCurrentUserRole() != "Supplier") return Forbid();
        var userId = GetCurrentUserId();
        var supplier = await _db.SupplierProfiles.FirstOrDefaultAsync(s => s.OwnerUserId == userId);
        if (supplier == null) return NotFound("Supplier profile not found");
        var supplierId = supplier.SupplierID;

        var ret = await _db.ReturnRequests
            .Include(r => r.MasterOrder).ThenInclude(m => m.SubOrders)
            .FirstOrDefaultAsync(r => r.Id == id && r.SupplierId == supplierId);
            
        if (ret == null) return NotFound();
        if (ret.Status != ReturnStatus.Approved) return BadRequest("Return must be approved first.");
        if (ret.ApprovedAmount == null || ret.ApprovedAmount <= 0) return BadRequest("Invalid refund amount.");

        var subOrder = ret.MasterOrder.SubOrders.FirstOrDefault();
        
        // 1. Process Stripe Refund
        try
        {
            var refundId = await _stripe.RefundPartialAsync(ret.MasterOrderId, ret.ApprovedAmount.Value, subOrder?.StripeTransferId);
            _logger.LogInformation("Processed refund {RefundId} for return {ReturnId}", refundId, ret.Id);
        }
        catch (Exception ex) when (ex.Message.Contains("No Stripe payment intent"))
        {
            _logger.LogWarning("Manual or offline order: No Stripe payment intent for order {OrderId}. Skipping Stripe refund.", ret.MasterOrderId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to process Stripe refund for return {ReturnId}", ret.Id);
            return BadRequest(new { error = "Payment gateway error: " + ex.Message });
        }

        // 2. Inventory Adjustment (Simple implementation: deduct from merchant, add to supplier)
        // Note: For a robust system, you would parse ItemsJson and adjust specific product inventories.
        // For MVP, we will assume successful physical transfer.

        ret.Status = ReturnStatus.Refunded;
        ret.UpdatedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync();
        await _notifications.NotifyMerchantAsync(ret.MerchantId, "ReturnRefunded", new { ret.Id, Amount = ret.ApprovedAmount });

        return Ok(new { message = "Refund processed successfully", returnRequest = ret });
    }
}

public class ReturnRequestDto
{
    public int MasterOrderId { get; set; }
    public string Reason { get; set; } = string.Empty;
    public List<string> Photos { get; set; } = new();
    public List<ReturnItemDto> Items { get; set; } = new();
    public decimal RequestedAmount { get; set; }
}

public class ReturnItemDto
{
    public int ProductId { get; set; }
    public int Quantity { get; set; }
}

public class ApproveReturnDto
{
    public decimal ApprovedAmount { get; set; }
}

public class RejectReturnDto
{
    public string Reason { get; set; } = string.Empty;
}
