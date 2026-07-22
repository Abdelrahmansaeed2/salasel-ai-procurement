using Salasel.Domain.Enums;

namespace Salasel.Domain.Entities;

public class OrderTransactions
{
    public int OrderID { get; set; }
    public int MerchantID { get; set; }
    public MerchantsProfile Merchant { get; set; } = null!;

    public int? VoiceLogID { get; set; }
    public VoiceProcurementLogs? VoiceLog { get; set; }

    public decimal TotalOrderCost { get; set; }
    public ApprovalStatus ApprovalStatus { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<OrderSplits> OrderSplits { get; set; } = new List<OrderSplits>();
}
