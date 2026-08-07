namespace Salasel.Application.DTOs;

// POST /api/v1/merchants/register-shop — 3-step shop registration wizard
public class MerchantSetupDto
{
    public string ShopName { get; set; } = string.Empty;
    public string OwnerName { get; set; } = string.Empty;
    public string CrNumber { get; set; } = string.Empty;
    public string OwnerIdentityNumber { get; set; } = string.Empty;
    public string ContactPhone { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public string StoreSize { get; set; } = string.Empty;
    public string Governorate { get; set; } = string.Empty;
    public string BusinessCity { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public decimal LocationLat { get; set; }
    public decimal LocationLng { get; set; }
}

// PUT /api/v1/merchants/me/shops/{id} and PUT /api/v1/merchants/me/profile
// (owner identity fields — OwnerName/CrNumber/OwnerIdentityNumber — are set
// once at registration and are intentionally not editable here, since
// changing them should require re-verification)
public class UpdateMerchantShopDto
{
    public string ShopName { get; set; } = string.Empty;
    public string ContactPhone { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public string StoreSize { get; set; } = string.Empty;
    public string Governorate { get; set; } = string.Empty;
    public string BusinessCity { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public decimal LocationLat { get; set; }
    public decimal LocationLng { get; set; }
}

// GET .../me/shops and GET .../me/shops/{id}
public class MerchantProfileDto
{
    public int MerchantID { get; set; }
    public string ShopName { get; set; } = string.Empty;
    public string OwnerName { get; set; } = string.Empty;
    public string CrNumber { get; set; } = string.Empty;
    public string OwnerIdentityNumber { get; set; } = string.Empty;
    public string ContactPhone { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public string StoreSize { get; set; } = string.Empty;
    public string Governorate { get; set; } = string.Empty;
    public string BusinessCity { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public decimal LocationLat { get; set; }
    public decimal LocationLng { get; set; }
    public bool IsVerified { get; set; }
    public string VerificationStatus { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

// GET .../me/shops/{id}/verification-status
public class MerchantVerificationStatusDto
{
    public int MerchantID { get; set; }
    public string VerificationStatus { get; set; } = string.Empty;
    public bool IsVerified { get; set; }

    // Voice ordering is gated behind CR/ID review clearing
    public bool VoiceOrderingLocked { get; set; }
    public int DocumentsUploadedCount { get; set; }
}

// POST .../me/shops/{id}/documents (multipart form upload)
public class MerchantDocumentDto
{
    public int Id { get; set; }
    public int MerchantID { get; set; }
    public string DocumentType { get; set; } = string.Empty;
    public string FileUrl { get; set; } = string.Empty;
    public DateTime UploadedAt { get; set; }
}

// GET/PUT /api/v1/merchants/me — account-level profile header
public class MerchantMeProfileDto
{
    public int UserID { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? ContactPhone { get; set; }
    public bool IsSetupCompleted { get; set; }
}

public class UpdateMerchantMeProfileDto
{
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? ContactPhone { get; set; }
}
