using Salasel.Domain.Enums;

namespace Salasel.Domain.Entities;

public class User
{
    public int UserID { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public UserRole Role { get; set; } // Merchant, Supplier, Admin
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public MerchantsProfile? MerchantsProfile { get; set; }
    public SupplierProfile? SupplierProfile { get; set; }
    public ICollection<SystemAuditLog> SystemAuditLogs { get; set; } = new List<SystemAuditLog>();
}
