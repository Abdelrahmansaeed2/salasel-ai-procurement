using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Salasel.Infrastructure.Data;

namespace Salasel.API.Controllers.VoiceChat;

[ApiController]
[Route("api/v1/voice-lookups")]
public class LookupsController : ControllerBase
{
    private readonly SalaselDbContext _db;

    public LookupsController(SalaselDbContext db) => _db = db;

    [HttpGet("merchants")]
    public async Task<IActionResult> Merchants() =>
        Ok(await _db.MerchantsProfiles
            .AsNoTracking()
            .Select(m => new
            {
                id = m.MerchantID,
                name = m.ShopName,
                latitude = m.LocationLat,
                longitude = m.LocationLng,
                phone = m.ContactPhone
            })
            .ToListAsync());

    [HttpGet("suppliers")]
    public async Task<IActionResult> Suppliers() =>
        Ok(await _db.SupplierProfiles
            .AsNoTracking()
            .Select(s => new
            {
                id = s.SupplierID,
                name = s.CompanyName,
                latitude = s.LocationLat,
                longitude = s.LocationLng,
                phone = s.ContactPhone,
                isActive = s.IsActiveForRouting
            })
            .ToListAsync());
}
