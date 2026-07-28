namespace Salasel.Domain.Entities;

public class Product
{
    public int Id { get; set; }

    public int CategoryId { get; set; }
    public Category Category { get; set; } = null!;

    public string Name { get; set; } = string.Empty;
    public string SKU { get; set; } = string.Empty;
    public string Unit { get; set; } = string.Empty;        // e.g. "kg", "box", "piece"
    public string? Description { get; set; }
    public string? ImageUrl { get; set; }
    public bool IsActive { get; set; } = true;

    public ICollection<MerchantInventory> MerchantInventories { get; set; } = new List<MerchantInventory>();
    public ICollection<SupplierProduct> SupplierProducts { get; set; } = new List<SupplierProduct>();
}
