namespace Salasel.Application.DTOs;

public class WarehouseDto
{
    public string City { get; set; } = string.Empty;
    public decimal Lat { get; set; }
    public decimal Lng { get; set; }
}

public class SupplierFacilityInfoDto
{
    public string LegalName { get; set; } = string.Empty;
    public string BusinessType { get; set; } = string.Empty;
    public string RegistrationNumber { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
}

public class SupplierContactInfoDto
{
    public string FullName { get; set; } = string.Empty;
    public string JobTitle { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
}

public class SupplierTaxInfoDto
{
    public string VatNumber { get; set; } = string.Empty;
    public string TaxId { get; set; } = string.Empty;
    public bool IsVatExempt { get; set; }
}

public class SupplierSetupWarehouseDto
{
    public string WarehouseName { get; set; } = string.Empty;
    public string Capacity { get; set; } = string.Empty;
    public decimal Lat { get; set; }
    public decimal Lng { get; set; }
    public string City { get; set; } = string.Empty;
}

// POST /api/v1/suppliers/register — consolidated wizard submission
public class SupplierSetupDto
{
    public SupplierFacilityInfoDto FacilityInfo { get; set; } = new();
    public SupplierContactInfoDto ContactInfo { get; set; } = new();
    public SupplierTaxInfoDto TaxInfo { get; set; } = new();
    public List<SupplierSetupWarehouseDto> Warehouses { get; set; } = new();

    // Kept for backward compatibility if needed, but the main data is now nested
    public string BankName { get; set; } = string.Empty;
    public string Iban { get; set; } = string.Empty;
}

// GET /api/v1/suppliers/me
public class SupplierProfileDto
{
    public int SupplierID { get; set; }
    public string CompanyName { get; set; } = string.Empty;
    public string ContactPhone { get; set; } = string.Empty;
    public string CrNumber { get; set; } = string.Empty;
    public string TaxNumber { get; set; } = string.Empty;
    public string BankName { get; set; } = string.Empty;
    public string Iban { get; set; } = string.Empty;
    public int RegistrationStep { get; set; }
    public bool IsSetupCompleted { get; set; }
    public decimal ReliabilityScore { get; set; }
    public bool IsActiveForRouting { get; set; }
    public string VerificationStatus { get; set; } = string.Empty;
    public bool IsStripeOnboardingComplete { get; set; }
    
    // New Settings Fields
    public string BusinessType { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string JobTitle { get; set; } = string.Empty;
    public decimal CoverageRadiusKm { get; set; }
    public string PaymentTerms { get; set; } = string.Empty;
    public string VatNumber { get; set; } = string.Empty;
    public bool IsVatExempt { get; set; }
    
    public List<WarehouseDto> Warehouses { get; set; } = new();
}

// PUT /api/v1/suppliers/me
public class UpdateSupplierProfileDto
{
    public string CompanyName { get; set; } = string.Empty;
    public string ContactPhone { get; set; } = string.Empty;
    public string BankName { get; set; } = string.Empty;
    public string Iban { get; set; } = string.Empty;
    
    public string Address { get; set; } = string.Empty;
    public string BusinessType { get; set; } = string.Empty;
    public string JobTitle { get; set; } = string.Empty;
    public string CrNumber { get; set; } = string.Empty;
    public string TaxNumber { get; set; } = string.Empty;
    public string VatNumber { get; set; } = string.Empty;
    public bool IsVatExempt { get; set; }
    public decimal CoverageRadiusKm { get; set; }
    public string PaymentTerms { get; set; } = string.Empty;
}

// GET /api/v1/suppliers/me/dashboard
public class SupplierDashboardDto
{
    public int RegistrationStep { get; set; }
    public bool IsSetupCompleted { get; set; }
    public int ActiveRfqs { get; set; }
    public int SubmittedBids { get; set; }
    public double SupplierRating { get; set; }
}

// GET /api/v1/suppliers/me/products — catalog table row
public class SupplierProductDto
{
    public int Id { get; set; }
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string SKU { get; set; } = string.Empty;
    public decimal UnitPrice { get; set; }
    public int AvailableQty { get; set; }
    public int MinOrderQty { get; set; }
    public int LeadTimeDays { get; set; }
    public bool IsActive { get; set; }
    public DateTime LastUpdated { get; set; }
}

// POST /api/v1/suppliers/me/products
public class CreateSupplierProductDto
{
    // Link to an existing catalog product...
    public int? ProductId { get; set; }

    // ...or create one on the fly if the supplier is listing something new.
    public string? NewProductName { get; set; }
    public string? NewProductSKU { get; set; }
    public string? NewProductUnit { get; set; }
    public int? NewProductCategoryId { get; set; }

    public decimal UnitPrice { get; set; }
    public int AvailableQty { get; set; }
    public int MinOrderQty { get; set; } = 1;
    public int LeadTimeDays { get; set; }
}

// PUT /api/v1/suppliers/me/products/{id}  (also used by PUT /api/v1/suppliers/catalogs/{id})
public class UpdateSupplierProductDto
{
    public decimal UnitPrice { get; set; }
    public int AvailableQty { get; set; }
    public int MinOrderQty { get; set; }
    public int LeadTimeDays { get; set; }
}

// GET /api/v1/categories
public class CategoryDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
}