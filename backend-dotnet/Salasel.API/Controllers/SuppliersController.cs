using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Domain.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/suppliers")]
[Authorize]
public class SuppliersController : ControllerBase
{
    private readonly IRepository<SupplierProfile> _repository;
    private readonly ISupplierProductRepository _productRepository;

    public SuppliersController(
        IRepository<SupplierProfile> repository,
        ISupplierProductRepository productRepository)
    {
        _repository = repository;
        _productRepository = productRepository;
    }

    [HttpGet]
    [AllowAnonymous] // Public directory
    public async Task<ActionResult<IEnumerable<SupplierProfile>>> GetAll()
    {
        var all = await _repository.GetAllAsync();
        var approved = all.Where(s => s.IsActiveForRouting).ToList();
        return Ok(approved);
    }

    [HttpGet("{id:int}")]
    [AllowAnonymous] // Public directory
    public async Task<ActionResult<SupplierProfile>> GetById(int id)
    {
        var supplier = await _repository.GetByIdAsync(id);
        if (supplier == null || !supplier.IsActiveForRouting) return NotFound();
        return Ok(supplier);
    }

    [HttpGet("{id:int}/catalog")]
    [AllowAnonymous]
    public async Task<IActionResult> GetCatalogBySupplierId(int id)
    {
        var supplier = await _repository.GetByIdAsync(id);
        if (supplier == null || !supplier.IsActiveForRouting) return NotFound();

        var products = await _productRepository.Query()
            .Include(sp => sp.Product)
            .ThenInclude(p => p.Category)
            .Where(sp => sp.SupplierId == id && sp.IsActive)
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

    [HttpPost]
    public async Task<ActionResult<SupplierProfile>> Create([FromBody] SupplierProfile supplier)
    {
        await _repository.AddAsync(supplier);
        await _repository.SaveChangesAsync();
        return CreatedAtAction(nameof(GetById), new { id = supplier.SupplierID }, supplier);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] SupplierProfile supplier)
    {
        if (id != supplier.SupplierID) return BadRequest("Route id does not match body SupplierID.");

        var existing = await _repository.GetByIdAsync(id);
        if (existing == null) return NotFound();

        existing.CompanyName = supplier.CompanyName;
        existing.ReliabilityScore = supplier.ReliabilityScore;
        existing.PaymentTerms = supplier.PaymentTerms;
        existing.IsActiveForRouting = supplier.IsActiveForRouting;

        await _repository.UpdateAsync(existing);
        await _repository.SaveChangesAsync();
        return NoContent();
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var existing = await _repository.GetByIdAsync(id);
        if (existing == null) return NotFound();

        await _repository.RemoveAsync(existing);
        await _repository.SaveChangesAsync();
        return NoContent();
    }
}
