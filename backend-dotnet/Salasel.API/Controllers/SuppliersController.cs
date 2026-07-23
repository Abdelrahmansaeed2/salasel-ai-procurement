using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Salasel.Domain.Entities;
using Salasel.Domain.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class SuppliersController : ControllerBase
{
    private readonly IRepository<SupplierProfile> _repository;

    public SuppliersController(IRepository<SupplierProfile> repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<SupplierProfile>>> GetAll()
    {
        return Ok(await _repository.GetAllAsync());
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<SupplierProfile>> GetById(int id)
    {
        var supplier = await _repository.GetByIdAsync(id);
        if (supplier == null) return NotFound();
        return Ok(supplier);
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