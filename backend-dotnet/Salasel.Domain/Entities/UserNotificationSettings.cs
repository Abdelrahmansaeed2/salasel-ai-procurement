namespace Salasel.Domain.Entities;

public class UserNotificationSettings
{
    public int Id { get; set; }

    public int UserId { get; set; }
    public User User { get; set; } = null!;

    public bool PushEnabled { get; set; } = true;
    public bool EmailEnabled { get; set; } = true;

    // Coarse per-category toggles rather than one flag per event name —
    // keeps this from needing a migration every time a new event is added.
    public bool OrderUpdates { get; set; } = true;   // confirm/cancel/approve/ship/deliver/etc.
    public bool BiddingUpdates { get; set; } = true; // new RFQ, bid accepted/rejected
    public bool InventoryAlerts { get; set; } = true; // low-stock / reorder suggestions
    public bool Marketing { get; set; } = false;

    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
