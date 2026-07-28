namespace Salasel.Domain.Entities;

public class VoiceProcurementLog
{
    public int Id { get; set; }
    public int MerchantId { get; set; }
    public MerchantsProfile Merchant { get; set; } = null!;

    public string? AudioUrl { get; set; }        // nullable: text commands have no audio
    public string? Transcript { get; set; }       // nullable: may not always be transcribed
    public string? RawTextInput { get; set; }     // if merchant typed instead of spoke
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public AIProcessing? AIProcessing { get; set; }
    public ICollection<MasterOrder> MasterOrders { get; set; } = new List<MasterOrder>();
}
