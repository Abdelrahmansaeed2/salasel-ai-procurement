using Salasel.Domain.Enums;

namespace Salasel.Domain.Entities;

public class MerchantDocument
{
    public int Id { get; set; }

    public int MerchantId { get; set; }
    public MerchantsProfile Merchant { get; set; } = null!;

    public MerchantDocumentType DocumentType { get; set; }
    public string FileUrl { get; set; } = string.Empty;
    public DateTime UploadedAt { get; set; } = DateTime.UtcNow;
}
