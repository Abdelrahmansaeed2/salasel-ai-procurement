using Salasel.Domain.Enums;

namespace Salasel.Domain.Entities;

public class SupplierKnowledgeDocument
{
    public int Id { get; set; }

    public int SupplierId { get; set; }
    public SupplierProfile Supplier { get; set; } = null!;

    public string FileName { get; set; } = string.Empty;
    public string FileUrl { get; set; } = string.Empty;
    public string FileType { get; set; } = string.Empty; // pdf / csv / xlsx

    public KnowledgeDocumentStatus Status { get; set; } = KnowledgeDocumentStatus.Processing;

    // Set once (fake) indexing completes — see KnowledgeIndexingWorker.
    public int? ChunkCount { get; set; }
    public string? ErrorMessage { get; set; }

    public DateTime UploadedAt { get; set; } = DateTime.UtcNow;
    public DateTime? IndexedAt { get; set; }
}