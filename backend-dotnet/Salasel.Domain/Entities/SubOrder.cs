using Salasel.Domain.Enums;

namespace Salasel.Domain.Entities;

public class SubOrder
{
    public int Id { get; set; }

    public int MasterId { get; set; }
    public MasterOrder MasterOrder { get; set; } = null!;

    public int SupplierId { get; set; }
    public SupplierProfile Supplier { get; set; } = null!;

    public int Quantity { get; set; }
    public decimal SubTotalAmount { get; set; }
    public FulfillmentStatus Status { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
}
