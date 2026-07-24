using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/orders")]
[Authorize(Roles = "Merchant,Admin")]
public class OrdersController : ControllerBase
{
    private readonly IOrderExecutionService _orderExecutionService;

    public OrdersController(IOrderExecutionService orderExecutionService)
    {
        _orderExecutionService = orderExecutionService;
    }

    [HttpPost("execute")]
    public async Task<IActionResult> ExecuteOrder([FromBody] OrderExecutionRequestDto request)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        if (request.Splits == null || request.Splits.Count == 0)
            return BadRequest("An order must contain at least one supplier split.");

        var orderId = await _orderExecutionService.ExecuteOrderAsync(request);
        return Ok(new { Message = "Order executed successfully", OrderID = orderId });
    }
}