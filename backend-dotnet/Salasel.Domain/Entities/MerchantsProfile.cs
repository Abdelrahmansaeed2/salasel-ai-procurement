namespace Salasel.Domain.Entities;

public class MerchantsProfile
{
    public int MerchantID { get; set; }

    public int OwnerUserId { get; set; }
    public User Owner { get; set; } = null!;

    public string ShopName { get; set; } = string.Empty;
    public decimal LocationLat { get; set; }
    public decimal LocationLng { get; set; }
    public string ContactPhone { get; set; } = string.Empty;
    public bool IsVerified { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<MerchantInventory> Inventories { get; set; } = new List<MerchantInventory>();
    public ICollection<VoiceProcurementLog> VoiceProcurementLogs { get; set; } = new List<VoiceProcurementLog>();
    public ICollection<MasterOrder> MasterOrders { get; set; } = new List<MasterOrder>();
}
