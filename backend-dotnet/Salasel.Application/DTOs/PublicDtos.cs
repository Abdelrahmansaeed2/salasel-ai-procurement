namespace Salasel.Application.DTOs;

// GET /api/v1/public/suppliers?q=&city=
public class PublicSupplierListItemDto
{
    public int SupplierID { get; set; }
    public string CompanyName { get; set; } = string.Empty;
    public List<string> Cities { get; set; } = new();
    public decimal ReliabilityScore { get; set; }
    public int ActiveProductCount { get; set; }
}

// GET /api/v1/public/suppliers/{id}
// Deliberately excludes compliance-sensitive fields (CrNumber, TaxNumber,
// BankName, Iban, exact lat/lng) — this is a public marketing page, not the
// supplier's own profile view.
public class PublicSupplierDetailDto
{
    public int SupplierID { get; set; }
    public string CompanyName { get; set; } = string.Empty;
    public string ContactPhone { get; set; } = string.Empty;
    public List<string> Cities { get; set; } = new();
    public decimal ReliabilityScore { get; set; }
    public int ActiveProductCount { get; set; }
    public DateTime MemberSince { get; set; }
}

// POST /api/v1/public/contact
public class ContactFormDto
{
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string? Subject { get; set; }
    public string Message { get; set; } = string.Empty;
}

// GET /api/v1/system/status
public class SystemStatusDto
{
    public string Status { get; set; } = "healthy"; // "healthy" | "degraded"
    public bool DatabaseConnected { get; set; }
    public string Environment { get; set; } = string.Empty;
    public string? Version { get; set; }
    public DateTime ServerTimeUtc { get; set; }
}
