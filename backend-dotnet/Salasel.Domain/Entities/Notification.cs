namespace Salasel.Domain.Entities;

// A durable record of every push NotificationService sends, so
// GET /api/v1/notifications has something to read — SignalR itself is
// fire-and-forget with nothing to query after the fact.
public class Notification
{
    public int Id { get; set; }

    // The account that should see this — resolved from the merchant/supplier
    // profile id NotificationService was called with, not the profile id itself,
    // since a user is who actually logs in and reads notifications.
    public int UserId { get; set; }
    public User User { get; set; } = null!;

    public string EventName { get; set; } = string.Empty; // "NewOrder", "OrderAccepted", etc.
    public string PayloadJson { get; set; } = string.Empty;

    public bool IsRead { get; set; } = false;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? ReadAt { get; set; }
}