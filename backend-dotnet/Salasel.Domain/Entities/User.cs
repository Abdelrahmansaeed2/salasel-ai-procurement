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

    public int TokenVersion { get; set; } = 0;

    // Flips true the first time the merchant/supplier fills in their real
    // profile (see MerchantsController/SuppliersController.Update).
    // Admins are created already "set up" — they have no onboarding step.
    public bool IsSetupCompleted { get; set; } = false;

    // PUT /api/v1/users/me/language — optional per the spec (client-only is
    // also acceptable), but persisting it means language survives a reinstall/new device.
    public string PreferredLanguage { get; set; } = "en";

    public ICollection<MerchantsProfile> MerchantsProfiles { get; set; } = new List<MerchantsProfile>();
    public ICollection<SupplierProfile> SupplierProfiles { get; set; } = new List<SupplierProfile>();
}
