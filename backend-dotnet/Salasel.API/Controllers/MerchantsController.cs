using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Domain.Enums;
using Salasel.Domain.Interfaces;
using Salasel.Infrastructure.Services;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/merchants")]
[Authorize]
public class MerchantsController : ControllerBase
{
    private static readonly string[] AllowedDocumentExtensions = { ".pdf", ".jpg", ".jpeg", ".png" };
    private const long MaxDocumentSizeBytes = 10 * 1024 * 1024; // 10 MB

    private readonly IRepository<MerchantsProfile> _repository;
    private readonly IRepository<MerchantDocument> _documentRepository;
    private readonly IUserRepository _userRepository;
    private readonly IMerchantDashboardService _dashboardService;
    private readonly IWebHostEnvironment _env;

    public MerchantsController(
        IRepository<MerchantsProfile> repository,
        IRepository<MerchantDocument> documentRepository,
        IUserRepository userRepository,
        IMerchantDashboardService dashboardService,
        IWebHostEnvironment env)
    {
        _repository = repository;
        _documentRepository = documentRepository;
        _userRepository = userRepository;
        _dashboardService = dashboardService;
        _env = env;
    }

    // ───────────────────────────── Admin CRUD ─────────────────────────────
    // Unrestricted merchant management for back-office/admin tooling.

    [HttpGet]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<IEnumerable<MerchantsProfile>>> GetAll()
    {
        return Ok(await _repository.GetAllAsync());
    }

    [HttpGet("{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<MerchantsProfile>> GetById(int id)
    {
        var merchant = await _repository.GetByIdAsync(id);
        if (merchant == null) return NotFound();
        return Ok(merchant);
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<MerchantsProfile>> Create([FromBody] MerchantsProfile merchant)
    {
        await _repository.AddAsync(merchant);
        await _repository.SaveChangesAsync();
        return CreatedAtAction(nameof(GetById), new { id = merchant.MerchantID }, merchant);
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Update(int id, [FromBody] MerchantsProfile merchant)
    {
        if (id != merchant.MerchantID) return BadRequest("Route id does not match body MerchantID.");

        var existing = await _repository.GetByIdAsync(id);
        if (existing == null) return NotFound();

        existing.ShopName = merchant.ShopName;
        existing.LocationLat = merchant.LocationLat;
        existing.LocationLng = merchant.LocationLng;
        existing.ContactPhone = merchant.ContactPhone;
        existing.IsVerified = merchant.IsVerified;

        await _repository.UpdateAsync(existing);
        await _repository.SaveChangesAsync();
        return NoContent();
    }

    [HttpDelete("{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Delete(int id)
    {
        var existing = await _repository.GetByIdAsync(id);
        if (existing == null) return NotFound();

        await _repository.RemoveAsync(existing);
        await _repository.SaveChangesAsync();
        return NoContent();
    }

    // ───────────────────────── Account profile ("me") ─────────────────────

    // GET /api/v1/merchants/me — profile header (name/email/phone).
    // Phone is pulled from the merchant's oldest shop, since User itself
    // has no phone field.
    [HttpGet("me")]
    [Authorize(Roles = "Merchant")]
    public async Task<IActionResult> GetMe()
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var user = await _userRepository.GetByIdAsync(userId.Value);
        if (user == null) return NotFound();

        var primaryShop = await GetPrimaryShopAsync(userId.Value);

        return Ok(new MerchantMeProfileDto
        {
            UserID = user.UserID,
            FullName = user.FullName,
            Email = user.Email,
            ContactPhone = primaryShop?.ContactPhone,
            IsSetupCompleted = user.IsSetupCompleted
        });
    }

    // PUT /api/v1/merchants/me — update name/email/phone.
    // Phone updates the oldest shop's ContactPhone, if the merchant has one.
    [HttpPut("me")]
    [Authorize(Roles = "Merchant")]
    public async Task<IActionResult> UpdateMe([FromBody] UpdateMerchantMeProfileDto request)
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var user = await _userRepository.GetByIdAsync(userId.Value);
        if (user == null) return NotFound();

        if (!string.Equals(user.Email, request.Email, StringComparison.OrdinalIgnoreCase)
            && await _userRepository.EmailExistsAsync(request.Email))
        {
            return BadRequest(new { Message = "Email already exists." });
        }

        user.FullName = request.FullName;
        user.Email = request.Email;
        await _userRepository.UpdateAsync(user);

        if (request.ContactPhone != null)
        {
            var primaryShop = await GetPrimaryShopAsync(userId.Value);
            if (primaryShop != null)
            {
                primaryShop.ContactPhone = request.ContactPhone;
                await _repository.UpdateAsync(primaryShop);
            }
        }

        await _userRepository.SaveChangesAsync();
        return Ok(new { Message = "Profile updated successfully." });
    }

    // DELETE /api/v1/users/me lives in UsersController, not here — see that
    // file for account deletion.

    // ─────────────────────────── Shops (multi-shop) ────────────────────────

    // GET /api/v1/merchants/me/shops — multi-shop Welcome screen
    [HttpGet("me/shops")]
    [Authorize(Roles = "Merchant")]
    public async Task<IActionResult> GetMyShops()
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var shops = await _repository.FindAsync(m => m.OwnerUserId == userId.Value);
        return Ok(shops.OrderBy(s => s.CreatedAt).Select(MapToDto));
    }

    // POST /api/v1/merchants/register-shop — 3-step shop registration wizard
    [HttpPost("register-shop")]
    [Authorize(Roles = "Merchant")]
    public async Task<IActionResult> RegisterShop([FromBody] MerchantSetupDto request)
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var shop = new MerchantsProfile
        {
            OwnerUserId = userId.Value,
            ShopName = request.ShopName,
            OwnerName = request.OwnerName,
            CrNumber = request.CrNumber,
            OwnerIdentityNumber = request.OwnerIdentityNumber,
            ContactPhone = request.ContactPhone,
            Category = request.Category,
            StoreSize = request.StoreSize,
            Governorate = request.Governorate,
            BusinessCity = request.BusinessCity,
            Address = request.Address,
            LocationLat = request.LocationLat,
            LocationLng = request.LocationLng,
            IsVerified = false,
            VerificationStatus = MerchantVerificationStatus.UnderReview,
            CreatedAt = DateTime.UtcNow
        };

        await _repository.AddAsync(shop);

        // Onboarding is complete once the merchant has registered a shop.
        var user = await _userRepository.GetByIdAsync(userId.Value);
        if (user != null && !user.IsSetupCompleted)
        {
            user.IsSetupCompleted = true;
            await _userRepository.UpdateAsync(user);
        }

        await _repository.SaveChangesAsync();

        return CreatedAtAction(nameof(GetShopDetail), new { id = shop.MerchantID }, MapToDto(shop));
    }

    // GET /api/v1/merchants/me/shops/{id} — shop detail
    [HttpGet("me/shops/{id:int}")]
    [Authorize(Roles = "Merchant")]
    public async Task<IActionResult> GetShopDetail(int id)
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var shop = await GetOwnedShopAsync(id, userId.Value);
        if (shop == null) return NotFound();

        return Ok(MapToDto(shop));
    }

    // PUT /api/v1/merchants/me/shops/{id} — edit shop
    [HttpPut("me/shops/{id:int}")]
    [Authorize(Roles = "Merchant")]
    public async Task<IActionResult> UpdateShop(int id, [FromBody] UpdateMerchantShopDto request)
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var shop = await GetOwnedShopAsync(id, userId.Value);
        if (shop == null) return NotFound();

        ApplyShopUpdate(shop, request);

        await _repository.UpdateAsync(shop);
        await _repository.SaveChangesAsync();

        return Ok(MapToDto(shop));
    }

    // PUT /api/v1/merchants/me/profile — quick edit of the oldest/primary shop
    // (shop name, category, location). Kept for clients built before the
    // multi-shop UI; prefer PUT .../me/shops/{id} for a specific shop.
    [HttpPut("me/profile")]
    [Authorize(Roles = "Merchant")]
    public async Task<IActionResult> UpdateMyProfile([FromBody] UpdateMerchantShopDto request)
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var shop = await GetPrimaryShopAsync(userId.Value);
        if (shop == null)
        {
            return NotFound(new { Message = "No shop found. Register a shop first via POST /api/v1/merchants/register-shop." });
        }

        ApplyShopUpdate(shop, request);

        await _repository.UpdateAsync(shop);
        await _repository.SaveChangesAsync();

        return Ok(MapToDto(shop));
    }

    // POST /api/v1/merchants/me/shops/{id}/submit-verification — send for CR review
    [HttpPost("me/shops/{id:int}/submit-verification")]
    [Authorize(Roles = "Merchant")]
    public async Task<IActionResult> SubmitVerification(int id)
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var shop = await _repository.SingleOrDefaultAsync(m => m.MerchantID == id && m.OwnerUserId == userId.Value);
        if (shop == null) return NotFound();

        if (shop.VerificationStatus == MerchantVerificationStatus.UnderReview
            || shop.VerificationStatus == MerchantVerificationStatus.Approved)
        {
            return BadRequest(new { Message = $"Shop is already {shop.VerificationStatus}." });
        }

        if (!await _documentRepository.ExistsAsync(d => d.MerchantId == shop.MerchantID))
        {
            return BadRequest(new { Message = "Upload your CR and ID documents before submitting for review." });
        }

        shop.VerificationStatus = MerchantVerificationStatus.UnderReview;
        await _repository.UpdateAsync(shop);
        await _repository.SaveChangesAsync();

        var docCount = await _documentRepository.CountAsync(d => d.MerchantId == shop.MerchantID);

        return Ok(new MerchantVerificationStatusDto
        {
            MerchantID = shop.MerchantID,
            VerificationStatus = shop.VerificationStatus.ToString(),
            IsVerified = shop.IsVerified,
            VoiceOrderingLocked = shop.VerificationStatus != MerchantVerificationStatus.Approved,
            DocumentsUploadedCount = docCount
        });
    }

    // GET /api/v1/merchants/me/shops/{id}/verification-status
    [HttpGet("me/shops/{id:int}/verification-status")]
    [Authorize(Roles = "Merchant")]
    public async Task<IActionResult> GetVerificationStatus(int id)
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var shop = await _repository.SingleOrDefaultAsync(m => m.MerchantID == id && m.OwnerUserId == userId.Value);
        if (shop == null) return NotFound();

        var docCount = await _documentRepository.CountAsync(d => d.MerchantId == shop.MerchantID);

        return Ok(new MerchantVerificationStatusDto
        {
            MerchantID = shop.MerchantID,
            VerificationStatus = shop.VerificationStatus.ToString(),
            IsVerified = shop.IsVerified,
            VoiceOrderingLocked = shop.VerificationStatus != MerchantVerificationStatus.Approved,
            DocumentsUploadedCount = docCount
        });
    }

    // POST /api/v1/merchants/me/shops/{id}/documents — upload CR / ID
    [HttpPost("me/shops/{id:int}/documents")]
    [Authorize(Roles = "Merchant")]
    [RequestSizeLimit(MaxDocumentSizeBytes)]
    public async Task<IActionResult> UploadDocument(int id, [FromForm] MerchantDocumentType documentType, [FromForm] IFormFile? file)
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var shop = await GetOwnedShopAsync(id, userId.Value);
        if (shop == null) return NotFound();

        if (file == null || file.Length == 0)
            return BadRequest(new { Message = "No file provided." });

        if (file.Length > MaxDocumentSizeBytes)
            return BadRequest(new { Message = "File exceeds the 10 MB size limit." });

        var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (string.IsNullOrEmpty(ext) || !AllowedDocumentExtensions.Contains(ext))
            return BadRequest(new { Message = "Invalid file type. Only PDF, JPG, and PNG are allowed." });

        var webRoot = _env.WebRootPath;
        if (string.IsNullOrEmpty(webRoot))
            webRoot = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");

        var uploadsDir = Path.Combine(webRoot, "uploads", "merchant-documents");
        Directory.CreateDirectory(uploadsDir);

        var storedName = $"{Guid.NewGuid():N}{ext}";
        var fullPath = Path.Combine(uploadsDir, storedName);

        await using (var stream = System.IO.File.Create(fullPath))
        {
            await file.CopyToAsync(stream);
        }

        var relativePath = PathHelpers.ToRelative(fullPath, webRoot);

        var document = new MerchantDocument
        {
            MerchantId = shop.MerchantID,
            DocumentType = documentType,
            FileUrl = relativePath,
            UploadedAt = DateTime.UtcNow
        };

        await _documentRepository.AddAsync(document);
        await _documentRepository.SaveChangesAsync();

        return Ok(new MerchantDocumentDto
        {
            Id = document.Id,
            MerchantID = document.MerchantId,
            DocumentType = document.DocumentType.ToString(),
            FileUrl = document.FileUrl,
            UploadedAt = document.UploadedAt
        });
    }

    // ─────────────────────────── Dashboard / home ──────────────────────────

    // GET /api/v1/merchants/me/dashboard — home KPIs + recent orders.
    // Uses the primary (oldest) shop, consistent with the other "me" endpoints
    // above; pass a shopId query param here later if multi-shop dashboards
    // are needed.
    [HttpGet("me/dashboard")]
    [Authorize(Roles = "Merchant")]
    public async Task<IActionResult> GetDashboard()
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var shop = await GetPrimaryShopAsync(userId.Value);
        if (shop == null)
        {
            return NotFound(new { Message = "No shop found. Register a shop first via POST /api/v1/merchants/register-shop." });
        }

        var dashboard = await _dashboardService.GetDashboardAsync(shop.MerchantID);
        return Ok(dashboard);
    }

    // GET /api/v1/merchants/me/recent-orders
    [HttpGet("me/recent-orders")]
    [Authorize(Roles = "Merchant")]
    public async Task<IActionResult> GetRecentOrders([FromQuery] int take = 10)
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var shop = await GetPrimaryShopAsync(userId.Value);
        if (shop == null)
        {
            return NotFound(new { Message = "No shop found. Register a shop first via POST /api/v1/merchants/register-shop." });
        }

        var orders = await _dashboardService.GetRecentOrdersAsync(shop.MerchantID, take);
        return Ok(orders);
    }

    // ───────────────────────────── Helpers ─────────────────────────────────

    private int? CurrentUserId()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(idStr, out var id) ? id : null;
    }

    private async Task<MerchantsProfile?> GetOwnedShopAsync(int shopId, int userId)
    {
        return await _repository.SingleOrDefaultAsync(m => m.MerchantID == shopId && m.OwnerUserId == userId);
    }

    private async Task<MerchantsProfile?> GetPrimaryShopAsync(int userId)
    {
        var shops = await _repository.FindAsync(m => m.OwnerUserId == userId);
        return shops.OrderBy(s => s.CreatedAt).FirstOrDefault();
    }

    private static void ApplyShopUpdate(MerchantsProfile shop, UpdateMerchantShopDto request)
    {
        shop.ShopName = request.ShopName;
        shop.ContactPhone = request.ContactPhone;
        shop.Category = request.Category;
        shop.StoreSize = request.StoreSize;
        shop.Governorate = request.Governorate;
        shop.BusinessCity = request.BusinessCity;
        shop.Address = request.Address;
        shop.LocationLat = request.LocationLat;
        shop.LocationLng = request.LocationLng;
    }

    private static MerchantProfileDto MapToDto(MerchantsProfile shop)
    {
        return new MerchantProfileDto
        {
            MerchantID = shop.MerchantID,
            ShopName = shop.ShopName,
            OwnerName = shop.OwnerName,
            CrNumber = shop.CrNumber,
            OwnerIdentityNumber = shop.OwnerIdentityNumber,
            ContactPhone = shop.ContactPhone,
            Category = shop.Category,
            StoreSize = shop.StoreSize,
            Governorate = shop.Governorate,
            BusinessCity = shop.BusinessCity,
            Address = shop.Address,
            LocationLat = shop.LocationLat,
            LocationLng = shop.LocationLng,
            IsVerified = shop.IsVerified,
            VerificationStatus = shop.VerificationStatus.ToString(),
            CreatedAt = shop.CreatedAt
        };
    }
}
