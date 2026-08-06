using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Domain.Enums;
using Salasel.Domain.Interfaces;
using System.Security.Claims;

namespace Salasel.API.Controllers;

// Supplier self-service endpoints, scoped to the caller's own account.
// Separate from SuppliersController (admin/general-purpose CRUD by id).
[ApiController]
[Route("api/v1/suppliers")]
[Authorize(Roles = "Supplier,Admin")]
public class SuppliersMeController : ControllerBase
{
    // Total steps in the frontend wizard. There's no per-step save endpoint —
    // the whole wizard is submitted as one SupplierSetupDto — so this is set
    // once, on successful registration, rather than incremented per call.
    private const int TotalRegistrationSteps = 8;

    private readonly ISupplierProfileRepository _supplierRepository;
    private readonly ISupplierProductRepository _productCatalogRepository;
    private readonly IRepository<SupplierWarehouse> _warehouseRepository;
    private readonly IRepository<Product> _productRepository;
    private readonly IRepository<SubOrder> _subOrderRepository;
    private readonly IRepository<Bid> _bidRepository;
    private readonly IUserRepository _userRepository;

    public SuppliersMeController(
        ISupplierProfileRepository supplierRepository,
        ISupplierProductRepository productCatalogRepository,
        IRepository<SupplierWarehouse> warehouseRepository,
        IRepository<Product> productRepository,
        IRepository<SubOrder> subOrderRepository,
        IRepository<Bid> bidRepository,
        IUserRepository userRepository)
    {
        _supplierRepository = supplierRepository;
        _productCatalogRepository = productCatalogRepository;
        _warehouseRepository = warehouseRepository;
        _productRepository = productRepository;
        _subOrderRepository = subOrderRepository;
        _bidRepository = bidRepository;
        _userRepository = userRepository;
    }

    // POST /api/v1/suppliers/register — multi-step wizard, submitted whole.
    // A bare SupplierProfile already exists from auth/register (see
    // AuthService.RegisterAsync) — this fills in the real details rather
    // than creating a second profile, since a supplier has exactly one.
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] SupplierSetupDto request)
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var supplier = await GetMySupplierAsync(userId.Value);
        if (supplier == null)
            return NotFound(new { Message = "No supplier profile exists for this account." });

        supplier.CompanyName = request.FacilityInfo.LegalName;
        supplier.BusinessType = request.FacilityInfo.BusinessType;
        supplier.CrNumber = request.FacilityInfo.RegistrationNumber;
        supplier.Address = request.FacilityInfo.Address;

        supplier.ContactPhone = request.ContactInfo.PhoneNumber;
        supplier.JobTitle = request.ContactInfo.JobTitle;

        supplier.TaxNumber = request.TaxInfo.TaxId;
        supplier.VatNumber = request.TaxInfo.VatNumber;
        supplier.IsVatExempt = request.TaxInfo.IsVatExempt;

        // The wizard doesn't explicitly collect Bank info right now, so these might be empty
        supplier.BankName = request.BankName ?? string.Empty;
        supplier.Iban = request.Iban ?? string.Empty;

        supplier.RegistrationStep = TotalRegistrationSteps;
        // Wizard completion doubles as the CR/verification submission — there's
        // no separate "submit-verification" step for suppliers like merchants have.
        supplier.VerificationStatus = MerchantVerificationStatus.UnderReview;

        await ReplaceWarehousesAsync(supplier.SupplierID, request.Warehouses);

        await _supplierRepository.UpdateAsync(supplier);
        await _supplierRepository.SaveChangesAsync();

        var owner = await _userRepository.GetByIdAsync(userId.Value);
        if (owner != null)
        {
            if (!string.IsNullOrWhiteSpace(request.ContactInfo.FullName))
            {
                owner.FullName = request.ContactInfo.FullName;
            }
            if (!owner.IsSetupCompleted)
            {
                owner.IsSetupCompleted = true;
            }
            await _userRepository.UpdateAsync(owner);
            await _userRepository.SaveChangesAsync();
        }

        return Ok(await ToProfileDtoAsync(supplier));
    }

    [HttpPost("me/documents")]
    public async Task<IActionResult> UploadDocuments([FromForm] IFormFileCollection files)
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var supplier = await GetMySupplierAsync(userId.Value);
        if (supplier == null) return NotFound();

        // In a real scenario, you'd upload these to S3 or Blob Storage
        // For now, just simulate success to satisfy the frontend wizard
        var savedFiles = new List<string>();
        foreach (var file in files)
        {
            if (file.Length > 0)
            {
                savedFiles.Add(file.FileName);
            }
        }

        return Ok(new { Message = "Documents uploaded successfully", Files = savedFiles });
    }

    [HttpGet("me")]
    public async Task<IActionResult> GetMe()
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var supplier = await GetMySupplierAsync(userId.Value);
        if (supplier == null) return NotFound();

        return Ok(await ToProfileDtoAsync(supplier));
    }

    [HttpPut("me")]
    public async Task<IActionResult> UpdateMe([FromBody] UpdateSupplierProfileDto request)
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var supplier = await GetMySupplierAsync(userId.Value);
        if (supplier == null) return NotFound();

        supplier.CompanyName = request.CompanyName;
        supplier.ContactPhone = request.ContactPhone;
        supplier.BankName = request.BankName;
        supplier.Iban = request.Iban;

        await _supplierRepository.UpdateAsync(supplier);
        await _supplierRepository.SaveChangesAsync();

        return Ok(await ToProfileDtoAsync(supplier));
    }

    [HttpGet("me/dashboard")]
    public async Task<IActionResult> GetDashboard()
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var supplier = await GetMySupplierAsync(userId.Value);
        if (supplier == null) return NotFound();

        // "Active" = still open and relevant to this supplier: unclaimed RFQs
        // in the shared pool, or ones they've already placed a bid on.
        var activeRfqs = await _subOrderRepository.Query()
            .Where(s => s.Status == FulfillmentStatus.Bidding
                     && (s.SupplierId == null || s.SupplierId == supplier.SupplierID))
            .CountAsync();

        var submittedBids = await _bidRepository.Query()
            .Where(b => b.SupplierId == supplier.SupplierID && b.Status == BidStatus.Submitted)
            .CountAsync();

        var owner = await _userRepository.GetByIdAsync(userId.Value);

        return Ok(new SupplierDashboardDto
        {
            RegistrationStep = supplier.RegistrationStep,
            IsSetupCompleted = owner?.IsSetupCompleted ?? false,
            ActiveRfqs = activeRfqs,
            SubmittedBids = submittedBids,
            // ReliabilityScore is 0-100; the UI shows a 0-5 star rating.
            SupplierRating = Math.Round((double)supplier.ReliabilityScore / 20.0, 1)
        });
    }

    // ─────────────────────────── Product catalog ───────────────────────────

    [HttpGet("me/products")]
    public async Task<IActionResult> GetMyProducts()
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var supplier = await GetMySupplierAsync(userId.Value);
        if (supplier == null) return NotFound();

        var products = await _productCatalogRepository.Query()
            .Include(sp => sp.Product)
            .Where(sp => sp.SupplierId == supplier.SupplierID)
            .Select(sp => ToProductDto(sp))
            .ToListAsync();

        return Ok(products);
    }

    [HttpPost("me/products")]
    public async Task<IActionResult> CreateProduct([FromBody] CreateSupplierProductDto request)
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var supplier = await GetMySupplierAsync(userId.Value);
        if (supplier == null) return NotFound();

        int productId;
        if (request.ProductId.HasValue)
        {
            var existing = await _productRepository.GetByIdAsync(request.ProductId.Value);
            if (existing == null) return BadRequest(new { Message = $"Product {request.ProductId} not found." });
            productId = existing.Id;
        }
        else
        {
            var newProduct = new Product
            {
                Name = request.NewProductName!,
                SKU = request.NewProductSKU!,
                Unit = request.NewProductUnit!,
                CategoryId = request.NewProductCategoryId!.Value,
                IsActive = true
            };
            await _productRepository.AddAsync(newProduct);
            await _productRepository.SaveChangesAsync();
            productId = newProduct.Id;
        }

        var alreadyListed = await _productCatalogRepository.ExistsAsync(
            sp => sp.SupplierId == supplier.SupplierID && sp.ProductId == productId);
        if (alreadyListed)
            return BadRequest(new { Message = "This product is already in your catalog — use PUT to edit it." });

        var supplierProduct = new SupplierProduct
        {
            SupplierId = supplier.SupplierID,
            ProductId = productId,
            UnitPrice = request.UnitPrice,
            AvailableQty = request.AvailableQty,
            MinOrderQty = request.MinOrderQty,
            LeadTimeDays = request.LeadTimeDays,
            IsActive = true,
            LastUpdated = DateTime.UtcNow
        };

        await _productCatalogRepository.AddAsync(supplierProduct);
        await _productCatalogRepository.SaveChangesAsync();

        var withProduct = await _productCatalogRepository.Query()
            .Include(sp => sp.Product)
            .FirstAsync(sp => sp.Id == supplierProduct.Id);

        return CreatedAtAction(nameof(GetMyProducts), null, ToProductDto(withProduct));
    }

    [HttpPut("me/products/{id:int}")]
    public async Task<IActionResult> UpdateProduct(int id, [FromBody] UpdateSupplierProductDto request)
    {
        var result = await UpdateSupplierProductInternalAsync(id, request);
        return result;
    }

    [HttpDelete("me/products/{id:int}")]
    public async Task<IActionResult> DeactivateProduct(int id)
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var supplier = await GetMySupplierAsync(userId.Value);
        if (supplier == null) return NotFound();

        var product = await _productCatalogRepository.GetByIdAsync(id);
        if (product == null || product.SupplierId != supplier.SupplierID) return NotFound();

        product.IsActive = false;
        product.LastUpdated = DateTime.UtcNow;

        await _productCatalogRepository.UpdateAsync(product);
        await _productCatalogRepository.SaveChangesAsync();

        return NoContent();
    }

    private async Task<IActionResult> UpdateSupplierProductInternalAsync(int id, UpdateSupplierProductDto request)
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var supplier = await GetMySupplierAsync(userId.Value);
        if (supplier == null) return NotFound();

        var product = await _productCatalogRepository.GetByIdAsync(id);
        if (product == null || product.SupplierId != supplier.SupplierID) return NotFound();

        product.UnitPrice = request.UnitPrice;
        product.AvailableQty = request.AvailableQty;
        product.MinOrderQty = request.MinOrderQty;
        product.LeadTimeDays = request.LeadTimeDays;
        product.LastUpdated = DateTime.UtcNow;

        await _productCatalogRepository.UpdateAsync(product);
        await _productCatalogRepository.SaveChangesAsync();

        var withProduct = await _productCatalogRepository.Query()
            .Include(sp => sp.Product)
            .FirstAsync(sp => sp.Id == product.Id);

        return Ok(ToProductDto(withProduct));
    }

    // ─────────────────────────────── Helpers ────────────────────────────────

    private Task<SupplierProfile?> GetMySupplierAsync(int userId) =>
        _supplierRepository.SingleOrDefaultAsync(s => s.OwnerUserId == userId);

    private async Task ReplaceWarehousesAsync(int supplierId, List<SupplierSetupWarehouseDto> warehouses)
    {
        var existing = await _warehouseRepository.FindAsync(w => w.SupplierId == supplierId);
        await _warehouseRepository.RemoveRangeAsync(existing);

        await _warehouseRepository.AddRangeAsync(warehouses.Select(w => new SupplierWarehouse
        {
            SupplierId = supplierId,
            WarehouseName = w.WarehouseName,
            Capacity = w.Capacity,
            City = w.City,
            Lat = w.Lat,
            Lng = w.Lng
        }));

        await _warehouseRepository.SaveChangesAsync();
    }

    private async Task<SupplierProfileDto> ToProfileDtoAsync(SupplierProfile supplier)
    {
        var owner = await _userRepository.GetByIdAsync(supplier.OwnerUserId);
        var warehouses = await _warehouseRepository.FindAsync(w => w.SupplierId == supplier.SupplierID);

        return new SupplierProfileDto
        {
            SupplierID = supplier.SupplierID,
            CompanyName = supplier.CompanyName,
            ContactPhone = supplier.ContactPhone,
            CrNumber = supplier.CrNumber,
            TaxNumber = supplier.TaxNumber,
            BankName = supplier.BankName,
            Iban = supplier.Iban,
            RegistrationStep = supplier.RegistrationStep,
            IsSetupCompleted = owner?.IsSetupCompleted ?? false,
            ReliabilityScore = supplier.ReliabilityScore,
            IsActiveForRouting = supplier.IsActiveForRouting,
            VerificationStatus = supplier.VerificationStatus.ToString(),
            Warehouses = warehouses.Select(w => new WarehouseDto { City = w.City, Lat = w.Lat, Lng = w.Lng }).ToList()
        };
    }

    private static SupplierProductDto ToProductDto(SupplierProduct sp) => new()
    {
        Id = sp.Id,
        ProductId = sp.ProductId,
        ProductName = sp.Product?.Name ?? string.Empty,
        SKU = sp.Product?.SKU ?? string.Empty,
        UnitPrice = sp.UnitPrice,
        AvailableQty = sp.AvailableQty,
        MinOrderQty = sp.MinOrderQty,
        LeadTimeDays = sp.LeadTimeDays,
        IsActive = sp.IsActive,
        LastUpdated = sp.LastUpdated
    };

    private int? CurrentUserId()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(idStr, out var id) ? id : null;
    }
}