using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Salasel.Domain.Entities;
using Salasel.Domain.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class MerchantsController : ControllerBase
{
    private readonly IRepository<MerchantsProfile> _repository;

    public MerchantsController(IRepository<MerchantsProfile> repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<MerchantsProfile>>> GetAll()
    {
        return Ok(await _repository.GetAllAsync());
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<MerchantsProfile>> GetById(int id)
    {
        var merchant = await _repository.GetByIdAsync(id);
        if (merchant == null) return NotFound();
        return Ok(merchant);
    }

    [HttpPost]
    public async Task<ActionResult<MerchantsProfile>> Create([FromBody] MerchantsProfile merchant)
    {
        await _repository.AddAsync(merchant);
        await _repository.SaveChangesAsync();
        return CreatedAtAction(nameof(GetById), new { id = merchant.MerchantID }, merchant);
    }

    [HttpPut("{id:int}")]
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
    public async Task<IActionResult> Delete(int id)
    {
        var existing = await _repository.GetByIdAsync(id);
        if (existing == null) return NotFound();

        await _repository.RemoveAsync(existing);
        await _repository.SaveChangesAsync();
        return NoContent();
    }
}