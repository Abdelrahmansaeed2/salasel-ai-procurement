using System.Text.Json;

namespace Salasel.Application.DTOs;

public class NotificationDto
{
    public int Id { get; set; }
    public string EventName { get; set; } = string.Empty;
    public JsonElement Payload { get; set; }
    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ReadAt { get; set; }
}