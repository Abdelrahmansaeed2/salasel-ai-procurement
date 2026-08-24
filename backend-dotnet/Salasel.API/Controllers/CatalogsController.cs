using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/suppliers/catalogs")]
[Authorize(Roles = "Supplier,Admin")]
public class CatalogsController : ControllerBase
{
    private readonly ICatalogService _catalogService;
    private readonly ISupplierProductRepository _productCatalogRepository;
    private readonly ISupplierProfileRepository _supplierRepository;

    public CatalogsController(
        ICatalogService catalogService,
        ISupplierProductRepository productCatalogRepository,
        ISupplierProfileRepository supplierRepository)
    {
        _catalogService = catalogService;
        _productCatalogRepository = productCatalogRepository;
        _supplierRepository = supplierRepository;
    }

    // NOTE: still a stub — accepts the file but doesn't parse or persist it
    // yet. Real PDF/CSV ingestion (and the "Future AI integration: RAG
    // Ingestion" comment below) is a separate, bigger task than this section.
    [HttpPost("upload")]
    public async Task<IActionResult> UploadCatalog([FromForm] IFormFile pdfCatalog)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        // Future AI integration: RAG Ingestion
        return Accepted(new { Message = "Catalog uploaded successfully", Id = Guid.NewGuid().ToString() });
    }

    // GET /api/v1/suppliers/catalogs — same underlying rows as
    // GET /api/v1/suppliers/me/products, exposed here too since both paths
    // were requested separately.
    [HttpGet]
    public async Task<IActionResult> GetCatalog()
    {
        var supplier = await GetMySupplierAsync();
        if (supplier == null) return NotFound();

        var products = await _productCatalogRepository.Query()
            .Include(sp => sp.Product)
            .Where(sp => sp.SupplierId == supplier.SupplierID)
            .Select(sp => new SupplierProductDto
            {
                Id = sp.Id,
                ProductId = sp.ProductId,
                ProductName = sp.Product.Name,
                SKU = sp.Product.SKU,
                CategoryName = sp.Product.Category != null ? sp.Product.Category.Name : string.Empty,
                ImageUrl = sp.Product.ImageUrl,
                UnitPrice = sp.UnitPrice,
                AvailableQty = sp.AvailableQty,
                MinOrderQty = sp.MinOrderQty,
                LeadTimeDays = sp.LeadTimeDays,
                IsActive = sp.IsActive,
                LastUpdated = sp.LastUpdated
            })
            .ToListAsync();

        return Ok(products);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> UpdateCatalogLine(int id, [FromBody] UpdateSupplierProductDto request)
    {
        var supplier = await GetMySupplierAsync();
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

        return Ok(new SupplierProductDto
        {
            Id = product.Id,
            ProductId = product.ProductId,
            UnitPrice = product.UnitPrice,
            AvailableQty = product.AvailableQty,
            MinOrderQty = product.MinOrderQty,
            LeadTimeDays = product.LeadTimeDays,
            IsActive = product.IsActive,
            LastUpdated = product.LastUpdated
        });
    }

    private Task<SupplierProfile?> GetMySupplierAsync()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(idStr, out var userId)) return Task.FromResult<SupplierProfile?>(null);

        return _supplierRepository.SingleOrDefaultAsync(s => s.OwnerUserId == userId);
    }
}