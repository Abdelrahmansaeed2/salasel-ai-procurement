using Microsoft.AspNetCore.Mvc;
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/procurement")]
public class ProcurementController : ControllerBase
{
    private readonly IProcurementService _procurementService;

    public ProcurementController(IProcurementService procurementService)
    {
        _procurementService = procurementService;
    }

    [HttpPost("voice")]
    public async Task<IActionResult> ProcessVoice([FromBody] VoiceProcurementRequestDto request)
    {
        var logId = await _procurementService.LogVoiceProcurementAsync(request);
        return Ok(new { Message = "Voice processed successfully", LogID = logId });
    }
}
