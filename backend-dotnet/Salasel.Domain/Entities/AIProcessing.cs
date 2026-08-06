namespace Salasel.Domain.Entities;

public class AIProcessing
{
    public int Id { get; set; }

    public int VoiceLogId { get; set; }
    public VoiceProcurementLog VoiceLog { get; set; } = null!;

    public string ModelUsed { get; set; } = string.Empty;   // e.g. "gpt-4o", "gemini-2.0-flash"
    public string Prompt { get; set; } = string.Empty;
    public string ParsedJson { get; set; } = string.Empty;
    public decimal Confidence { get; set; }
    public int? ProcessingDurationMs { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}