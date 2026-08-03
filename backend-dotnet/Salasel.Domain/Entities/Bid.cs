using Salasel.Domain.Enums;
using System.Net.NetworkInformation;

namespace Salasel.Domain.Entities;

public class Bid
{
    public int Id { get; set; }

    public int SubOrderId { get; set; }
    public SubOrder SubOrder { get; set; } = null!;

    public int SupplierId { get; set; }
    public SupplierProfile Supplier { get; set; } = null!;

    public decimal Price { get; set; }
    public string? Notes { get; set; }

    public BidStatus Status { get; set; } = BidStatus.Submitted;
    public DateTime SubmittedAt { get; set; } = DateTime.UtcNow;
    public DateTime? DecidedAt { get; set; }
}
