using Salasel.Domain.Enums;

namespace Salasel.Domain.Entities;

public class MerchantsProfile
{
    public int MerchantID { get; set; }

    public int OwnerUserId { get; set; }
    public User Owner { get; set; } = null!;

    public string ShopName { get; set; } = string.Empty;

    // Owner / legal identity — collected during the shop registration wizard
    // (see MerchantSetupDto / MerchantsController.RegisterShop)
    public string OwnerName { get; set; } = string.Empty;
    public string CrNumber { get; set; } = string.Empty;
    public string OwnerIdentityNumber { get; set; } = string.Empty;

    // Shop classification & address
    public string Category { get; set; } = string.Empty;
    public string StoreSize { get; set; } = string.Empty;
    public string Governorate { get; set; } = string.Empty;
    public string BusinessCity { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;

    public decimal LocationLat { get; set; }
    public decimal LocationLng { get; set; }
    public string ContactPhone { get; set; } = string.Empty;

    // CR/ID review pipeline. IsVerified is kept in sync with
    // VerificationStatus == Approved for callers that only care about
    // the boolean (voice ordering gate, existing admin tooling, etc).
    public bool IsVerified { get; set; }
    public MerchantVerificationStatus VerificationStatus { get; set; } = MerchantVerificationStatus.NotSubmitted;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<MerchantInventory> Inventories { get; set; } = new List<MerchantInventory>();
    public ICollection<VoiceProcurementLog> VoiceProcurementLogs { get; set; } = new List<VoiceProcurementLog>();
    public ICollection<MasterOrder> MasterOrders { get; set; } = new List<MasterOrder>();
    public ICollection<MerchantDocument> Documents { get; set; } = new List<MerchantDocument>();
}
