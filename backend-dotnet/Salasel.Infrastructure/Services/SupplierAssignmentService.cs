using Microsoft.EntityFrameworkCore;
using Salasel.Infrastructure.Data;

namespace Salasel.Infrastructure.Services;

public interface ISupplierAssignmentService
{
    Task<int> GetNearestSupplierAsync(int merchantId, CancellationToken ct = default);
}

public class SupplierAssignmentService : ISupplierAssignmentService
{
    private readonly SalaselDbContext _db;

    public SupplierAssignmentService(SalaselDbContext db)
    {
        _db = db;
    }

    public async Task<int> GetNearestSupplierAsync(int merchantId, CancellationToken ct = default)
    {
        var merchant = await _db.MerchantsProfiles
            .FirstOrDefaultAsync(m => m.MerchantID == merchantId, ct);

        if (merchant == null)
            throw new InvalidOperationException($"Merchant {merchantId} not found.");

        var suppliers = await _db.SupplierProfiles
            .Where(s => s.IsActiveForRouting)
            .ToListAsync(ct);

        if (suppliers.Count == 0)
        {
            // Fallback: any supplier if none marked active
            suppliers = await _db.SupplierProfiles.ToListAsync(ct);
        }

        if (suppliers.Count == 0)
            throw new InvalidOperationException("No suppliers available for assignment.");

        var nearest = suppliers
            .OrderBy(s => GeoHelper.DistanceKm(
                (double)merchant.LocationLat,
                (double)merchant.LocationLng,
                (double)s.LocationLat,
                (double)s.LocationLng))
            .First();

        return nearest.SupplierID;
    }
}
