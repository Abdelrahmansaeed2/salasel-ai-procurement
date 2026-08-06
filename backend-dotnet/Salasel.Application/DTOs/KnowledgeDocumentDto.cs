namespace Salasel.Application.DTOs;

// GET /api/v1/suppliers/me/knowledge — list item
public class KnowledgeDocumentDto
{
    public int Id { get; set; }
    public string FileName { get; set; } = string.Empty;
    public string FileType { get; set; } = string.Empty;
    public string FileUrl { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public int? ChunkCount { get; set; }
    public string? ErrorMessage { get; set; }
    public DateTime UploadedAt { get; set; }
    public DateTime? IndexedAt { get; set; }
}