using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Salasel.Application.DTOs;
using Salasel.Domain.Entities;
using Salasel.Domain.Interfaces;
using Salasel.Infrastructure.Data;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/admin/settings")]
[Authorize(Roles = "Admin")]
public class AdminSettingsController : ControllerBase
{
    private readonly SalaselDbContext _db;

    public AdminSettingsController(SalaselDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    public async Task<IActionResult> GetSettings()
    {
        var settings = await _db.SystemConfigurations.ToListAsync();
        var dtos = settings.Select(s => new SystemConfigurationDto
        {
            Id = s.Id,
            Key = s.Key,
            Value = s.Value,
            Description = s.Description,
            LastUpdated = s.LastUpdated
        });
        return Ok(dtos);
    }

    [HttpPut("{key}")]
    public async Task<IActionResult> UpdateSetting(string key, [FromBody] UpdateSystemConfigurationDto request)
    {
        var setting = await _db.SystemConfigurations.FirstOrDefaultAsync(s => s.Key == key);
        if (setting == null)
        {
            // If it doesn't exist, create it (allows dynamic seeding from UI if needed)
            setting = new SystemConfiguration
            {
                Key = key,
                Value = request.Value,
                Description = "Dynamically added configuration",
                LastUpdated = DateTime.UtcNow
            };
            _db.SystemConfigurations.Add(setting);
        }
        else
        {
            setting.Value = request.Value;
            setting.LastUpdated = DateTime.UtcNow;
            _db.SystemConfigurations.Update(setting);
        }

        await _db.SaveChangesAsync();

        return Ok(new SystemConfigurationDto
        {
            Id = setting.Id,
            Key = setting.Key,
            Value = setting.Value,
            Description = setting.Description,
            LastUpdated = setting.LastUpdated
        });
    }
}
