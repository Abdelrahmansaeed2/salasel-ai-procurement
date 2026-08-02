using Salasel.Domain.Enums;

namespace Salasel.Domain.Entities;

public class SubOrder
{
    public int Id { get; set; }

    public int MasterId { get; set; }
    public MasterOrder MasterOrder { get; set; } = null!;

    public int? SupplierId { get; set; }
    public SupplierProfile? Supplier { get; set; }

    public int? ProductId { get; set; }
    public Product? Product { get; set; }

    public int Quantity { get; set; }
    public decimal SubTotalAmount { get; set; }
    public FulfillmentStatus Status { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }

    // Competitive bids while Status == Bidding and SupplierId is still null.
    public ICollection<Bid> Bids { get; set; } = new List<Bid>();

    // Delivery tracking (GET .../tracking) + optional driver assignment
    public string? DriverName { get; set; }
    public string? DriverPhone { get; set; }
    public DateTime? AcceptedAt { get; set; }
    public DateTime? ShippedAt { get; set; }
    public DateTime? DeliveredAt { get; set; }
    public DateTime? ReceiptConfirmedAt { get; set; }
}