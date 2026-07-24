using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/procurement")]
[Authorize]
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
        if (audioFile == null || audioFile.Length == 0)
            return BadRequest(new { Message = "Audio file is required." });

        // Future AI integration: Transcribe and parse with LangGraph
        return Accepted(new { Message = "Voice processed successfully", LogID = Guid.NewGuid().ToString() });
    }
}
