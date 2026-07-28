namespace Salasel.Domain.Entities;

public class SupplierProfile
{
    public int SupplierID { get; set; }

    public int OwnerUserId { get; set; }
    public User Owner { get; set; } = null!;

    public string CompanyName { get; set; } = string.Empty;
    public string ContactPhone { get; set; } = string.Empty;

    // Location - used by AI to find nearest/best supplier
    public decimal LocationLat { get; set; }
    public decimal LocationLng { get; set; }
    public decimal CoverageRadiusKm { get; set; }

    public decimal ReliabilityScore { get; set; }  // 0-100, updated after each delivery
    public string PaymentTerms { get; set; } = string.Empty;
    public bool IsActiveForRouting { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<SubOrder> SubOrders { get; set; } = new List<SubOrder>();
    public ICollection<SupplierProduct> SupplierProducts { get; set; } = new List<SupplierProduct>();
}
