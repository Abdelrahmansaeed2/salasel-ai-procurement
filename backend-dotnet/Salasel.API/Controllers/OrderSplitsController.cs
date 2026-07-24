using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Salasel.Domain.Entities;
using Salasel.Domain.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class OrderSplitsController : ControllerBase
{
    private readonly IRepository<OrderSplit> _repository;

    public OrderSplitsController(IRepository<OrderSplit> repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<OrderSplit>>> GetAll()
    {
        return Ok(await _repository.GetAllAsync());
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<OrderSplit>> GetById(int id)
    {
        var split = await _repository.GetByIdAsync(id);
        if (split == null) return NotFound();
        return Ok(split);
    }

    [HttpGet("order/{parentOrderId:int}")]
    public async Task<ActionResult<IEnumerable<OrderSplit>>> GetByParentOrder(int parentOrderId)
    {
        return Ok(await _repository.FindAsync(s => s.ParentOrderID == parentOrderId));
    }

    [HttpGet("supplier/{supplierId:int}")]
    public async Task<ActionResult<IEnumerable<OrderSplit>>> GetBySupplier(int supplierId)
    {
        return Ok(await _repository.FindAsync(s => s.SupplierID == supplierId));
    }

    [HttpPost]
    public async Task<ActionResult<OrderSplit>> Create([FromBody] OrderSplit split)
    {
        await _repository.AddAsync(split);
        await _repository.SaveChangesAsync();
        return CreatedAtAction(nameof(GetById), new { id = split.SplitID }, split);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] OrderSplit split)
    {
        if (id != split.SplitID) return BadRequest("Route id does not match body SplitID.");

        var existing = await _repository.GetByIdAsync(id);
        if (existing == null) return NotFound();

        existing.SKU = split.SKU;
        existing.QuantityOrdered = split.QuantityOrdered;
        existing.SubTotalCost = split.SubTotalCost;
        existing.FulfillmentStatus = split.FulfillmentStatus;

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