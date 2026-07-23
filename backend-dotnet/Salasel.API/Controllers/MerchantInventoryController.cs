using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Salasel.Domain.Entities;
using Salasel.Domain.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class MerchantInventoryController : ControllerBase
{
    private readonly IRepository<MerchantInventory> _repository;

    public MerchantInventoryController(IRepository<MerchantInventory> repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<MerchantInventory>>> GetAll()
    {
        return Ok(await _repository.GetAllAsync());
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<MerchantInventory>> GetById(int id)
    {
        var item = await _repository.GetByIdAsync(id);
        if (item == null) return NotFound();
        return Ok(item);
    }

    [HttpGet("merchant/{merchantId:int}")]
    public async Task<ActionResult<IEnumerable<MerchantInventory>>> GetByMerchant(int merchantId)
    {
        return Ok(await _repository.FindAsync(i => i.MerchantID == merchantId));
    }

    [HttpPost]
    public async Task<ActionResult<MerchantInventory>> Create([FromBody] MerchantInventory item)
    {
        item.LastUpdated = DateTime.UtcNow;
        await _repository.AddAsync(item);
        await _repository.SaveChangesAsync();
        return CreatedAtAction(nameof(GetById), new { id = item.InventoryID }, item);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] MerchantInventory item)
    {
        if (id != item.InventoryID) return BadRequest("Route id does not match body InventoryID.");

        var existing = await _repository.GetByIdAsync(id);
        if (existing == null) return NotFound();

        existing.SKU = item.SKU;
        existing.CurrentQuantity = item.CurrentQuantity;
        existing.ReorderThreshold = item.ReorderThreshold;
        existing.LastUpdated = DateTime.UtcNow;

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