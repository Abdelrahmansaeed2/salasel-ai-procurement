using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Salasel.Application.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/inventory")]
[Authorize]
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
        var inventory = await _inventoryService.GetInventoryStatusAsync(merchantId);
        return Ok(inventory);
    }
}
