namespace Salasel.Domain.Entities;

public class MerchantsProfile
{
    public int MerchantID { get; set; }
    public User User { get; set; } = null!;

    public string ShopName { get; set; } = string.Empty;
    public decimal LocationLat { get; set; }
    public decimal LocationLng { get; set; }
    public string ContactPhone { get; set; } = string.Empty;
    public bool IsVerified { get; set; }

    public ICollection<MerchantInventory> Inventories { get; set; } = new List<MerchantInventory>();
    public ICollection<VoiceProcurementLogs> VoiceProcurementLogs { get; set; } = new List<VoiceProcurementLogs>();
    public ICollection<OrderTransactions> OrderTransactions { get; set; } = new List<OrderTransactions>();
}
