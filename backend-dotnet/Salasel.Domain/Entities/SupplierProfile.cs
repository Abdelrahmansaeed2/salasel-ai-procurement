namespace Salasel.Domain.Entities;

public class SupplierProfile
{
    public int SupplierID { get; set; }
    public User User { get; set; } = null!;

    public string CompanyName { get; set; } = string.Empty;
    public decimal ReliabilityScore { get; set; }
    public string PaymentTerms { get; set; } = string.Empty;
    public bool IsActiveForRouting { get; set; }

    public ICollection<OrderSplit> OrderSplits { get; set; } = new List<OrderSplit>();
    public ICollection<SupplierCatalog> SupplierCatalogs { get; set; } = new List<SupplierCatalog>();
}
