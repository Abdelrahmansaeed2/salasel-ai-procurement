using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
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

        // Future AI integration: Transcribe and parse with LangGraph
        return Accepted(new { Message = "Voice processed successfully", LogID = Guid.NewGuid().ToString() });
    }
}