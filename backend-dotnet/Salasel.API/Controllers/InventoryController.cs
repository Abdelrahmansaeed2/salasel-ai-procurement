using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Salasel.Application.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/inventory")]
[Authorize(Roles = "Merchant,Admin")]
public class InventoryController : ControllerBase
{
    private readonly IInventoryService _inventoryService;

    public InventoryController(IInventoryService inventoryService)
    {
        _inventoryService = inventoryService;
    }

    [HttpGet("status")]
    public async Task<IActionResult> GetInventoryStatus([FromQuery] int merchantId)
    {
        if (merchantId <= 0) return BadRequest("A valid merchantId is required.");

        var inventory = await _inventoryService.GetInventoryStatusAsync(merchantId);
        return Ok(inventory);
    }
}