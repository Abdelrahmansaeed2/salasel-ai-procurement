using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Salasel.Domain.Entities;
using Salasel.Infrastructure.Data;
using Salasel.Infrastructure.Services;

namespace Salasel.API.Controllers.VoiceChat;

[ApiController]
[Route("api/v1/voice")]
public class VoiceController : ControllerBase
{
    private readonly SalaselDbContext _db;
    private readonly IBackgroundQueue _queue;
    private readonly IWebHostEnvironment _env;
    private readonly ILogger<VoiceController> _logger;

    public VoiceController(
        SalaselDbContext db,
        IBackgroundQueue queue,
        IWebHostEnvironment env,
        ILogger<VoiceController> logger)
    {
        _db = db;
        _queue = queue;
        _env = env;
        _logger = logger;
    }

    [HttpPost("upload")]
    [RequestSizeLimit(20 * 1024 * 1024)]
    public async Task<IActionResult> Upload([FromForm] IFormFile? file, [FromForm] int merchantId)
    {
        if (file == null || file.Length == 0)
            return BadRequest(new { error = "No audio file provided." });

        var merchant = await _db.MerchantsProfiles
            .FirstOrDefaultAsync(m => m.MerchantID == merchantId);
        if (merchant is null)
            return NotFound(new { error = $"Merchant {merchantId} not found." });

        var webRoot = _env.WebRootPath;
        if (string.IsNullOrEmpty(webRoot))
            webRoot = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");

        var uploadsDir = Path.Combine(webRoot, "uploads");
        Directory.CreateDirectory(uploadsDir);

        var allowed = new[] { ".webm", ".mp3", ".wav", ".ogg", ".mp4" };
        var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (string.IsNullOrEmpty(ext) || !allowed.Contains(ext))
            return BadRequest(new { error = "Invalid file type. Only audio files are allowed." });

        var storedName = $"{Guid.NewGuid():N}{ext}";
        var fullPath = Path.Combine(uploadsDir, storedName);

        await using (var stream = System.IO.File.Create(fullPath))
        {
            await file.CopyToAsync(stream);
        }

        var relativePath = PathHelpers.ToRelative(fullPath, webRoot);

        var voiceLog = new VoiceProcurementLog
        {
            MerchantId = merchantId,
            AudioUrl = relativePath,
            CreatedAt = DateTime.UtcNow
        };

        _db.VoiceProcurementLogs.Add(voiceLog);
        await _db.SaveChangesAsync();

        await _queue.EnqueueAsync(new VoiceProcessingJob(voiceLog.Id, merchantId, relativePath));

        _logger.LogInformation(
            "Voice log {Id} queued for merchant {MerchantId}",
            voiceLog.Id, merchantId);

        return Ok(new
        {
            uploadId = voiceLog.Id,
            message = "Voice uploaded. AI is processing your order."
        });
    }

    [HttpGet("uploads")]
    public async Task<IActionResult> List([FromQuery] int merchantId)
    {
        var list = await _db.VoiceProcurementLogs
            .AsNoTracking()
            .Where(v => v.MerchantId == merchantId)
            .OrderByDescending(v => v.CreatedAt)
            .Select(v => new
            {
                v.Id,
                v.MerchantId,
                v.AudioUrl,
                v.Transcript,
                v.CreatedAt,
                hasAi = v.AIProcessing != null,
                orderIds = v.MasterOrders.Select(o => o.Id)
            })
            .ToListAsync();

        return Ok(list);
    }
}
