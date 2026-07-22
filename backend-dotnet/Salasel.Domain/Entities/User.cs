using Salasel.Domain.Enums;

namespace Salasel.Domain.Entities;

public class User
{
    public int UserID { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty; // Merchant, Supplier, Admin
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public MerchantsProfile? MerchantsProfile { get; set; }
    public SupplierProfile? SupplierProfile { get; set; }
    public ICollection<SystemAuditLogs> SystemAuditLogs { get; set; } = new List<SystemAuditLogs>();
}
