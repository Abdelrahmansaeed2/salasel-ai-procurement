using System.Security.Claims;
using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Salasel.Application.DTOs;
using Salasel.Infrastructure.Data;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/notifications")]
[Authorize]
public class NotificationsController : ControllerBase
{
    private readonly SalaselDbContext _db;

    public NotificationsController(SalaselDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    public async Task<IActionResult> GetMyNotifications([FromQuery] bool unreadOnly = false)
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var query = _db.Notifications.AsNoTracking().Where(n => n.UserId == userId.Value);
        if (unreadOnly) query = query.Where(n => !n.IsRead);

        var notifications = await query
            .OrderByDescending(n => n.CreatedAt)
            .Select(n => new { n.Id, n.EventName, n.PayloadJson, n.IsRead, n.CreatedAt, n.ReadAt })
            .ToListAsync();

        var result = notifications.Select(n => new NotificationDto
        {
            Id = n.Id,
            EventName = n.EventName,
            Payload = SafeParse(n.PayloadJson),
            IsRead = n.IsRead,
            CreatedAt = n.CreatedAt,
            ReadAt = n.ReadAt
        });

        return Ok(result);
    }

    [HttpPut("{id:int}/read")]
    public async Task<IActionResult> MarkRead(int id)
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var notification = await _db.Notifications
            .FirstOrDefaultAsync(n => n.Id == id && n.UserId == userId.Value);
        if (notification == null) return NotFound();

        if (!notification.IsRead)
        {
            notification.IsRead = true;
            notification.ReadAt = DateTime.UtcNow;
            await _db.SaveChangesAsync();
        }

        return NoContent();
    }

    private static JsonElement SafeParse(string json)
    {
        try
        {
            return JsonSerializer.Deserialize<JsonElement>(json);
        }
        catch (JsonException)
        {
            return JsonSerializer.Deserialize<JsonElement>("{}");
        }
    }

    private int? CurrentUserId()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(idStr, out var id) ? id : null;
    }
}