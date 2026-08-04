namespace Salasel.Domain.Entities;

public class SupplierProduct
{
    public int Id { get; set; }

    public int SupplierId { get; set; }
    public SupplierProfile Supplier { get; set; } = null!;

    public int ProductId { get; set; }
    public Product Product { get; set; } = null!;

    public decimal UnitPrice { get; set; }
    public int AvailableQty { get; set; }
    public int MinOrderQty { get; set; }      // minimum units the supplier accepts per order
    public int LeadTimeDays { get; set; }     // estimated delivery time in days
    public bool IsActive { get; set; } = true; // DELETE /me/products/{id} deactivates rather than hard-deletes
    public DateTime LastUpdated { get; set; } = DateTime.UtcNow;
}