using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Salasel.Domain.Entities;
using Salasel.Domain.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin")]
public class FraudPreventionLimitsController : ControllerBase
{
    private readonly IRepository<FraudPreventionLimit> _repository;

    public FraudPreventionLimitsController(IRepository<FraudPreventionLimit> repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<FraudPreventionLimit>>> GetAll()
    {
        return Ok(await _repository.GetAllAsync());
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<FraudPreventionLimit>> GetById(int id)
    {
        var rule = await _repository.GetByIdAsync(id);
        if (rule == null) return NotFound();
        return Ok(rule);
    }

    [HttpPost]
    public async Task<ActionResult<FraudPreventionLimit>> Create([FromBody] FraudPreventionLimit rule)
    {
        await _repository.AddAsync(rule);
        await _repository.SaveChangesAsync();
        return CreatedAtAction(nameof(GetById), new { id = rule.RuleID }, rule);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] FraudPreventionLimit rule)
    {
        if (id != rule.RuleID) return BadRequest("Route id does not match body RuleID.");

        var existing = await _repository.GetByIdAsync(id);
        if (existing == null) return NotFound();

        existing.RuleType = rule.RuleType;
        existing.HardLimitValue = rule.HardLimitValue;
        existing.IsActive = rule.IsActive;

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