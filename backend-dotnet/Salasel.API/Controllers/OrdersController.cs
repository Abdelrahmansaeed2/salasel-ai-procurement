using Microsoft.AspNetCore.Mvc;
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/orders")]
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
        var orderId = await _orderExecutionService.ExecuteOrderAsync(request);
        return Ok(new { Message = "Order executed successfully", OrderID = orderId });
    }
}
