namespace Salasel.Application.DTOs;

public class VoiceProcurementRequestDto
{
    public int MerchantID { get; set; }
    public string RawAudioURL { get; set; } = string.Empty;
    public string TranscribedAmiyaText { get; set; } = string.Empty;
    public string LLMParsedJSON { get; set; } = string.Empty;
    public decimal NLPConfidenceScore { get; set; }
}
