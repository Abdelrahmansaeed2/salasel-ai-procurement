namespace Salasel.Domain.Entities;

public class SystemAuditLog
{
    public int AuditID { get; set; }
    public int AdminUserID { get; set; }
    public User AdminUser { get; set; } = null!;

    public string ActionPerformed { get; set; } = string.Empty;
    public string TargetTable { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
}
