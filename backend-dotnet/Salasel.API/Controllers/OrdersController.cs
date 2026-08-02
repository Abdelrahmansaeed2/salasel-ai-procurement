using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/orders")]
[Authorize(Roles = "Merchant,Admin")]
public class OrdersController : ControllerBase
{
    private readonly IOrderExecutionService _orderExecutionService;
    private readonly IOrderQueryService _orderQueryService;
    private readonly IMerchantProfileRepository _merchantRepository;

    public OrdersController(
        IOrderExecutionService orderExecutionService,
        IOrderQueryService orderQueryService,
        IMerchantProfileRepository merchantRepository)
    {
        _orderExecutionService = orderExecutionService;
        _orderQueryService = orderQueryService;
        _merchantRepository = merchantRepository;
    }

    [HttpPost("execute")]
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
    public async Task<IActionResult> GetSummary([FromQuery] int merchantId)
    {
        if (merchantId <= 0) return BadRequest(new { Message = "A valid merchantId is required." });
        if (!await CanAccessMerchantAsync(merchantId)) return Forbid();

        var summary = await _orderQueryService.GetOrderSummaryAsync(merchantId);
        return Ok(summary);
    }

    private async Task<bool> CanAccessMerchantAsync(int merchantId)
    {
        if (User.IsInRole("Admin")) return true;

        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var userId)) return false;

        var shop = await _merchantRepository.SingleOrDefaultAsync(m => m.MerchantID == merchantId && m.OwnerUserId == userId);
        return shop != null;
    }
}
