namespace Salasel.Domain.Entities;

public class VoiceProcurementLogs
{
    public int LogID { get; set; }
    public int MerchantID { get; set; }
    public MerchantsProfile Merchant { get; set; } = null!;

    public string RawAudioURL { get; set; } = string.Empty;
    public string TranscribedAmiyaText { get; set; } = string.Empty;
    public string LLMParsedJSON { get; set; } = string.Empty;
    public decimal NLPConfidenceScore { get; set; }
    public DateTime ProcessedAt { get; set; } = DateTime.UtcNow;

    public ICollection<OrderTransactions> OrderTransactions { get; set; } = new List<OrderTransactions>();
}
