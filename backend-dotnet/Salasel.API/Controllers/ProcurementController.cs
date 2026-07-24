using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/procurement")]
[Authorize(Roles = "Merchant,Admin")]
public class ProcurementController : ControllerBase
{
    private readonly IProcurementService _procurementService;

    public ProcurementController(IProcurementService procurementService)
    {
        _procurementService = procurementService;
    }

    [HttpPost("voice")]
    public async Task<IActionResult> ProcessVoice([FromForm] IFormFile audioFile)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var logId = await _procurementService.LogVoiceProcurementAsync(request);
        return Ok(new { Message = "Voice processed successfully", LogID = logId });
    }
}