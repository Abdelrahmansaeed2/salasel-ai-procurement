using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
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

    public OrdersController(
        IOrderExecutionService orderExecutionService,
        IOrderQueryService orderQueryService,
        IBiddingService biddingService,
        IMerchantProfileRepository merchantRepository,
        ISupplierProfileRepository supplierRepository,
        IRepository<MasterOrder> masterOrderRepository,
        INotificationService notifications)
    {
        _orderExecutionService = orderExecutionService;
        _orderQueryService = orderQueryService;
        _biddingService = biddingService;
        _merchantRepository = merchantRepository;
        _supplierRepository = supplierRepository;
        _masterOrderRepository = masterOrderRepository;
        _notifications = notifications;
    }

    [HttpPost("execute")]
    [Authorize(Roles = "Merchant,Admin")]
    public async Task<IActionResult> ExecuteOrder([FromBody] OrderExecutionRequestDto request)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        if (request.Splits == null || request.Splits.Count == 0)
            return BadRequest("An order must contain at least one supplier split.");

        var Id = await _orderExecutionService.ExecuteOrderAsync(request);
        return Ok(new { Message = "Order executed successfully", Id = Id });
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
    public async Task<IActionResult> GetKanban([FromQuery] int supplierId)
    {
        if (supplierId <= 0) return BadRequest(new { Message = "A valid supplierId is required." });
        if (!await CanAccessSupplierAsync(supplierId)) return Forbid();

        var kanban = await _biddingService.GetKanbanAsync(supplierId);
        return Ok(kanban);
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
