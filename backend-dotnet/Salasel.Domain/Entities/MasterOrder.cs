using Salasel.Domain.Enums;

namespace Salasel.Domain.Entities;

public class MasterOrder
{
    public int Id { get; set; }

    public int MerchantId { get; set; }
    public MerchantsProfile Merchant { get; set; } = null!;

    public int? VoiceLogID { get; set; }
    public VoiceProcurementLog? VoiceLog { get; set; }

    public decimal TotalAmount { get; set; }
    public ApprovalStatus Status { get; set; }
    public OrderSource Source { get; set; }     // Voice, Manual, AI_Auto
    public string? Notes { get; set; }
    public DateTime OrderDate { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }

    public ICollection<SubOrder> SubOrders { get; set; } = new List<SubOrder>();
}
