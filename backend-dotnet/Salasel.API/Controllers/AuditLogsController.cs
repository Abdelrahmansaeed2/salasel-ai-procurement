using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Salasel.Domain.Entities;
using Salasel.Domain.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin")]
public class AuditLogsController : ControllerBase
{
    private readonly IRepository<SystemAuditLog> _repository;

    public AuditLogsController(IRepository<SystemAuditLog> repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<SystemAuditLog>>> GetAll()
    {
        return Ok(await _repository.GetAllAsync());
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<SystemAuditLog>> GetById(int id)
    {
        var log = await _repository.GetByIdAsync(id);
        if (log == null) return NotFound();
        return Ok(log);
    }

    [HttpGet("admin/{adminUserId:int}")]
    public async Task<ActionResult<IEnumerable<SystemAuditLog>>> GetByAdmin(int adminUserId)
    {
        return Ok(await _repository.FindAsync(a => a.AdminUserID == adminUserId));
    }

    [HttpPost]
    public async Task<ActionResult<SystemAuditLog>> Create([FromBody] SystemAuditLog log)
    {
        log.Timestamp = DateTime.UtcNow;
        await _repository.AddAsync(log);
        await _repository.SaveChangesAsync();
        return CreatedAtAction(nameof(GetById), new { id = log.AuditID }, log);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] SystemAuditLog log)
    {
        if (id != log.AuditID) return BadRequest("Route id does not match body AuditID.");

        var existing = await _repository.GetByIdAsync(id);
        if (existing == null) return NotFound();

        existing.ActionPerformed = log.ActionPerformed;
        existing.TargetTable = log.TargetTable;

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