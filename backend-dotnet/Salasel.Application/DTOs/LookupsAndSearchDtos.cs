namespace Salasel.Application.DTOs;

public class LookupItemDto
{
    public string Value { get; set; } = string.Empty;
    public string Label { get; set; } = string.Empty;
}

// GET /api/v1/products/search?q=
public class ProductSearchResultDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string SKU { get; set; } = string.Empty;
    public string Unit { get; set; } = string.Empty;
    public int CategoryId { get; set; }
    public string CategoryName { get; set; } = string.Empty;
    public string? ImageUrl { get; set; }
}

// GET /api/v1/search/orders?q=
public class OrderSearchResultDto
{
    public int Id { get; set; }
    public string MerchantName { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
    public DateTime OrderDate { get; set; }
}

// GET /api/v1/search/suppliers?q=
public class SupplierSearchResultDto
{
    public int SupplierID { get; set; }
    public string CompanyName { get; set; } = string.Empty;
    public decimal ReliabilityScore { get; set; }
}
