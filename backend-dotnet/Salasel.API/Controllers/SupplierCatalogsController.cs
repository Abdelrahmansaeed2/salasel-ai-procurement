using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Salasel.Domain.Entities;
using Salasel.Domain.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class SupplierCatalogsController : ControllerBase
{
    private readonly IRepository<SupplierCatalog> _repository;

    public SupplierCatalogsController(IRepository<SupplierCatalog> repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<SupplierCatalog>>> GetAll()
    {
        return Ok(await _repository.GetAllAsync());
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<SupplierCatalog>> GetById(int id)
    {
        var item = await _repository.GetByIdAsync(id);
        if (item == null) return NotFound();
        return Ok(item);
    }

    [HttpGet("supplier/{supplierId:int}")]
    public async Task<ActionResult<IEnumerable<SupplierCatalog>>> GetBySupplier(int supplierId)
    {
        return Ok(await _repository.FindAsync(c => c.SupplierID == supplierId));
    }

    [HttpPost]
    public async Task<ActionResult<SupplierCatalog>> Create([FromBody] SupplierCatalog item)
    {
        item.UpdatedAt = DateTime.UtcNow;
        await _repository.AddAsync(item);
        await _repository.SaveChangesAsync();
        return CreatedAtAction(nameof(GetById), new { id = item.CatalogID }, item);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] SupplierCatalog item)
    {
        if (id != item.CatalogID) return BadRequest("Route id does not match body CatalogID.");

        var existing = await _repository.GetByIdAsync(id);
        if (existing == null) return NotFound();

        existing.SKU = item.SKU;
        existing.ProductName = item.ProductName;
        existing.UnitPrice = item.UnitPrice;
        existing.StockAvailable = item.StockAvailable;
        existing.DeliveryLeadTime_Days = item.DeliveryLeadTime_Days;
        existing.VectorEmbedding = item.VectorEmbedding;
        existing.UpdatedAt = DateTime.UtcNow;

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