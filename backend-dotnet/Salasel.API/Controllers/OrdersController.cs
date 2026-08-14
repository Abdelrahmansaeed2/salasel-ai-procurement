using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Domain.Interfaces;
using Salasel.Domain.Enums;
using Salasel.Infrastructure.Services;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/orders")]
[Authorize] // per-action [Authorize(Roles=...)] below narrows this further
public class OrdersController : ControllerBase
{
    private readonly IOrderExecutionService _orderExecutionService;
    private readonly IOrderQueryService _orderQueryService;
    private readonly IBiddingService _biddingService;
    private readonly IMerchantProfileRepository _merchantRepository;
    private readonly ISupplierProfileRepository _supplierRepository;
    private readonly IRepository<MasterOrder> _masterOrderRepository;
    private readonly INotificationService _notifications;
    private readonly IPaymentService _paymentService;

    public OrdersController(
        IOrderExecutionService orderExecutionService,
        IOrderQueryService orderQueryService,
        IBiddingService biddingService,
        IMerchantProfileRepository merchantRepository,
        ISupplierProfileRepository supplierRepository,
        IRepository<MasterOrder> masterOrderRepository,
        INotificationService notifications,
        IPaymentService paymentService)
    {
        _orderExecutionService = orderExecutionService;
        _orderQueryService = orderQueryService;
        _biddingService = biddingService;
        _merchantRepository = merchantRepository;
        _supplierRepository = supplierRepository;
        _masterOrderRepository = masterOrderRepository;
        _notifications = notifications;
        _paymentService = paymentService;
    }

    [HttpPost("execute")]
    [Authorize(Roles = "Merchant,Admin")]
    public async Task<IActionResult> ExecuteOrder([FromBody] OrderExecutionRequestDto request)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        if (request.Splits == null || request.Splits.Count == 0)
            return BadRequest("An order must contain at least one supplier split.");

        var Id = await _orderExecutionService.ExecuteOrderAsync(request);
        
        var order = await _masterOrderRepository.GetByIdAsync(Id);
        string? clientSecret = null;
        if (order != null)
        {
            clientSecret = await _paymentService.CreatePaymentIntentAsync(order);
        }

        return Ok(new { Message = "Order executed successfully", Id = Id, ClientSecret = clientSecret });
    }

    // GET /api/v1/orders/summary?merchantId= — active total + % vs last month
    [HttpGet("summary")]
    [Authorize(Roles = "Merchant,Admin")]
    public async Task<IActionResult> GetSummary([FromQuery] int merchantId)
    {
        if (merchantId <= 0) return BadRequest(new { Message = "A valid merchantId is required." });
        if (!await CanAccessMerchantAsync(merchantId)) return Forbid();

        var summary = await _orderQueryService.GetOrderSummaryAsync(merchantId);
        return Ok(summary);
    }

    [HttpGet("{id:int}")]
    [Authorize(Roles = "Merchant,Admin")]
    public async Task<IActionResult> GetById(int id)
    {
        if (!await CanAccessOrderAsMerchantAsync(id)) return Forbid();

        try
        {
            var order = await _orderQueryService.GetOrderByIdAsync(id);
            return Ok(order);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { Message = ex.Message });
        }
    }

    // ──────────────────────────── Bidding / RFQ ────────────────────────────

    // POST /api/v1/orders/rfqs — merchant asks multiple suppliers to quote on
    // a product. Nothing else in the pipeline opens a line up to bidding
    // (voice orders auto-assign one supplier immediately), so this had to be
    // added for the rest of section 7 to have anything to operate on.
    [HttpPost("rfqs")]
    [Authorize(Roles = "Merchant,Admin")]
    public async Task<IActionResult> CreateRfq([FromBody] CreateRfqDto request)
    {
        if (!await CanAccessMerchantAsync(request.MerchantId)) return Forbid();

        try
        {
            var id = await _biddingService.CreateRfqAsync(request);
            return Ok(new { Message = "RFQ created and open for bidding.", MasterOrderId = id });
        }
        catch (Exception ex) when (ex is KeyNotFoundException or InvalidOperationException)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }

    // GET /api/v1/orders/rfqs/kanban?supplierId= — supplier's kanban board
    [HttpGet("rfqs/kanban")]
    [Authorize(Roles = "Supplier,Admin")]
    public async Task<IActionResult> GetKanban([FromQuery] int? supplierId)
    {
        int? targetId = supplierId ?? await CurrentSupplierIdAsync();
        if (targetId == null) return Forbid();
        if (!await CanAccessSupplierAsync(targetId.Value)) return Forbid();

        var kanban = await _biddingService.GetKanbanAsync(targetId.Value);
        return Ok(kanban);
    }

    [HttpGet("rfqs")]
    [Authorize(Roles = "Supplier,Admin")]
    public async Task<IActionResult> GetSupplierOrdersFeed([FromQuery] int? supplierId)
    {
        int? targetId = supplierId ?? await CurrentSupplierIdAsync();
        if (targetId == null) return Forbid();
        if (!await CanAccessSupplierAsync(targetId.Value)) return Forbid();

        var ordersFeed = await _biddingService.GetSupplierOrdersFeedAsync(targetId.Value);
        return Ok(ordersFeed);
    }

    // PUT /api/v1/orders/rfqs/{id}/bid — id = SubOrderId (the "SUB-xx" card).
    // Body carries no supplierId — it's resolved from the caller's own
    // supplier profile so one supplier can't bid on another's behalf.
    [HttpPut("rfqs/{id:int}/bid")]
    [Authorize(Roles = "Supplier")]
    public async Task<IActionResult> SubmitBid(int id, [FromBody] SubmitBidDto request)
    {
        var supplierId = await CurrentSupplierIdAsync();
        if (supplierId == null) return Forbid();

        try
        {
            var bid = await _biddingService.SubmitBidAsync(id, supplierId.Value, request);
            return Ok(bid);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { Message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }

    // GET /api/v1/orders/{id}/bids — merchant sees bids for their order
    [HttpGet("{id:int}/bids")]
    [Authorize(Roles = "Merchant,Admin")]
    public async Task<IActionResult> GetBids(int id)
    {
        if (!await CanAccessOrderAsMerchantAsync(id)) return Forbid();

        var bids = await _biddingService.GetBidsAsync(id);
        return Ok(bids);
    }

    // PUT /api/v1/orders/{id}/bids/{bidId}/accept — merchant accepts a bid
    [HttpPut("{id:int}/bids/{bidId:int}/accept")]
    [Authorize(Roles = "Merchant,Admin")]
    public async Task<IActionResult> AcceptBid(int id, int bidId)
    {
        if (!await CanAccessOrderAsMerchantAsync(id)) return Forbid();

        try
        {
            var bid = await _biddingService.AcceptBidAsync(id, bidId);
            await _notifications.NotifySupplierAsync(bid.SupplierId, "BidAccepted", bid);
            return Ok(bid);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { Message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }

    // PUT /api/v1/orders/rfqs/{id}/status — id = SubOrderId, drag-drop status
    [HttpPut("rfqs/{id:int}/status")]
    [Authorize(Roles = "Supplier")]
    public async Task<IActionResult> UpdateRfqStatus(int id, [FromBody] RfqStatusUpdateDto request)
    {
        var supplierId = await CurrentSupplierIdAsync();
        if (supplierId == null) return Forbid();

        try
        {
            await _biddingService.UpdateRfqStatusAsync(id, supplierId.Value, request.Status);
            return Ok(new { Message = "Status updated." });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { Message = ex.Message });
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }

    // PUT /api/v1/orders/voice/{id}/dispatch
    [HttpPut("voice/{id:int}/dispatch")]
    [Authorize(Roles = "Supplier")]
    public async Task<IActionResult> DispatchOrder(int id)
    {
        var supplierId = await CurrentSupplierIdAsync();
        if (supplierId == null) return Forbid();

        try
        {
            // Moving to Shipped status
            await _biddingService.UpdateRfqStatusAsync(id, supplierId.Value, FulfillmentStatus.Shipped.ToString());
            return Ok(new { Message = "Order dispatched successfully." });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { Message = ex.Message });
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }

    [HttpPost("{id:int}/payment")]
    [Authorize(Roles = "Merchant,Admin")]
    public async Task<IActionResult> ProcessPayment(int id, [FromBody] PaymentRequestDto request)
    {
        if (!await CanAccessOrderAsMerchantAsync(id)) return Forbid();

        var order = await _masterOrderRepository.GetByIdAsync(id);
        if (order == null) return NotFound(new { Message = "Order not found." });

        if (order.PaymentStatus == PaymentStatus.Paid)
            return BadRequest(new { Message = "Order is already paid." });

        order.PaymentMethod = request.PaymentMethod;

        if (request.PaymentMethod == PaymentMethod.CashOnDelivery)
        {
            order.PaymentStatus = PaymentStatus.Pending;
        }
        else
        {
            order.PaymentStatus = PaymentStatus.Paid;
            order.PaidAt = DateTime.UtcNow;
            order.PaymentReference = request.PaymentReference;
        }

        await _masterOrderRepository.UpdateAsync(order);
        await _masterOrderRepository.SaveChangesAsync();

        return Ok(new { Message = "Payment processed successfully.", OrderId = order.Id });
    }

    [HttpGet("{id:int}/tracking")]
    [Authorize(Roles = "Merchant,Admin")]
    public async Task<IActionResult> GetOrderTracking(int id)
    {
        if (!await CanAccessOrderAsMerchantAsync(id)) return Forbid();

        var order = await _masterOrderRepository.Query()
            .Include(o => o.SubOrders)
            .FirstOrDefaultAsync(o => o.Id == id);
            
        if (order == null) return NotFound(new { Message = "Order not found." });

        var subOrders = order.SubOrders.ToList();
        var driverSubOrder = subOrders.FirstOrDefault(s => !string.IsNullOrEmpty(s.DriverName));

        return Ok(new {
            OrderId = order.Id,
            AcceptedAt = subOrders.Any() ? subOrders.Min(s => s.AcceptedAt) : null,
            ShippedAt = subOrders.Any() ? subOrders.Min(s => s.ShippedAt) : null,
            DeliveredAt = subOrders.Any() ? subOrders.Min(s => s.DeliveredAt) : null,
            ReceiptConfirmedAt = subOrders.Any() ? subOrders.Min(s => s.ReceiptConfirmedAt) : null,
            DriverName = driverSubOrder?.DriverName,
            DriverPhone = driverSubOrder?.DriverPhone
        });
    }

    [HttpPost("{id:int}/confirm-receipt")]
    [Authorize(Roles = "Merchant,Admin")]
    public async Task<IActionResult> ConfirmReceipt(int id)
    {
        if (!await CanAccessOrderAsMerchantAsync(id)) return Forbid();

        var order = await _masterOrderRepository.Query()
            .Include(o => o.SubOrders)
            .FirstOrDefaultAsync(o => o.Id == id);
            
        if (order == null) return NotFound(new { Message = "Order not found." });

        bool updated = false;
        foreach (var sub in order.SubOrders)
        {
            if (sub.Status != FulfillmentStatus.ReceiptConfirmed)
            {
                sub.Status = FulfillmentStatus.ReceiptConfirmed;
                sub.ReceiptConfirmedAt = DateTime.UtcNow;
                updated = true;
            }
        }
        
        if (updated)
        {
            order.Status = ApprovalStatus.Completed;
            order.UpdatedAt = DateTime.UtcNow;
            await _masterOrderRepository.UpdateAsync(order);
            await _masterOrderRepository.SaveChangesAsync();
        }

        return Ok(new { Message = "Receipt confirmed successfully." });
    }

    // ───────────────────────────── Helpers ─────────────────────────────────

    private async Task<bool> CanAccessMerchantAsync(int merchantId)
    {
        if (User.IsInRole("Admin")) return true;

        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var userId)) return false;

        var shop = await _merchantRepository.SingleOrDefaultAsync(m => m.MerchantID == merchantId && m.OwnerUserId == userId);
        return shop != null;
    }

    private async Task<bool> CanAccessSupplierAsync(int supplierId)
    {
        if (User.IsInRole("Admin")) return true;

        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var userId)) return false;

        var supplier = await _supplierRepository.SingleOrDefaultAsync(s => s.SupplierID == supplierId && s.OwnerUserId == userId);
        return supplier != null;
    }

    // Resolves the calling user's own SupplierProfile — bid/status actions
    // don't take a supplierId in the body, precisely so a supplier can't act
    // on another supplier's behalf by just changing an id in the payload.
    private async Task<int?> CurrentSupplierIdAsync()
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var userId)) return null;

        var supplier = await _supplierRepository.SingleOrDefaultAsync(s => s.OwnerUserId == userId);
        return supplier?.SupplierID;
    }

    private async Task<bool> CanAccessOrderAsMerchantAsync(int masterOrderId)
    {
        if (User.IsInRole("Admin")) return true;

        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var userId)) return false;

        var order = await _masterOrderRepository.GetByIdAsync(masterOrderId);
        if (order == null) return false;

        var shop = await _merchantRepository.SingleOrDefaultAsync(m => m.MerchantID == order.MerchantId && m.OwnerUserId == userId);
        return shop != null;
    }
}
