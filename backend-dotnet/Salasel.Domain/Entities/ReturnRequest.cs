using System;

namespace Salasel.Domain.Entities;

public enum ReturnStatus
{
    Pending,
    Approved,
    Rejected,
    Escalated,
    Refunded,
    Closed
}

public class ReturnRequest
{
    public int Id { get; set; }
    
    // Core references
    public int MasterOrderId { get; set; }
    public MasterOrder MasterOrder { get; set; } = null!;

    public int MerchantId { get; set; }
    public MerchantsProfile Merchant { get; set; } = null!;

    public int? SupplierId { get; set; }
    public SupplierProfile? Supplier { get; set; }

    // Payload details
    public string Reason { get; set; } = string.Empty;
    public string PhotosJson { get; set; } = "[]"; // Serialized list of URLs
    public string ItemsJson { get; set; } = "[]"; // Serialized list of items/quantities being returned
    
    // Financials
    public decimal RequestedAmount { get; set; }
    public decimal? ApprovedAmount { get; set; }

    // Status
    public ReturnStatus Status { get; set; } = ReturnStatus.Pending;

    // Timestamps
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
}
