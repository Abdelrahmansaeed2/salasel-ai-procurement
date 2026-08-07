using System.Text;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Salasel.Infrastructure.Data;

namespace Salasel.Infrastructure.Services;

/// <summary>
/// Pushes the backend's live product/supplier catalog into the ai_service Qdrant
/// snapshot via <c>POST /api/v1/admin/products</c> (idempotent batch upsert). The
/// backend is the source of truth; this keeps the AI retrieval index in sync.
/// </summary>
public interface IAISyncService
{
    /// <summary>Full resync of every routable supplier's active product listings.</summary>
    Task<AiSyncResult> SyncAllActiveProductsAsync(CancellationToken ct = default);
}

public class AiSyncResult
{
    public int Attempted { get; set; }
    public bool Succeeded { get; set; }
    public string? Error { get; set; }
}

public class AISyncService : IAISyncService
{
    private readonly SalaselDbContext _db;
    private readonly HttpClient _http;
    private readonly ILogger<AISyncService> _logger;

    public AISyncService(SalaselDbContext db, HttpClient http, ILogger<AISyncService> logger)
    {
        _db = db;
        _http = http;
        _logger = logger;
    }

    public async Task<AiSyncResult> SyncAllActiveProductsAsync(CancellationToken ct = default)
    {
        var listings = await _db.SupplierProducts
            .AsNoTracking()
            .Where(sp => sp.IsActive
                      && sp.Supplier.IsActiveForRouting
                      && sp.Product.IsActive)
            .Select(sp => new ProductUpsertDto
            {
                ProductId = sp.ProductId,
                SupplierId = sp.SupplierId,
                ProductName = sp.Product.Name,
                Sku = sp.Product.SKU,
                Category = sp.Product.Category.Name,
                Description = sp.Product.Description ?? "",
                Unit = sp.Product.Unit,
                Price = (double)sp.UnitPrice,
                Lat = (double)sp.Supplier.LocationLat,
                Lon = (double)sp.Supplier.LocationLng,
                InStock = sp.AvailableQty > 0
            })
            .ToListAsync(ct);

        if (listings.Count == 0)
        {
            _logger.LogInformation("AISyncService: no active product listings to sync.");
            return new AiSyncResult { Attempted = 0, Succeeded = true };
        }

        _logger.LogInformation("AISyncService: syncing {Count} product listings to ai_service", listings.Count);

        var payload = new ProductUpsertBatchDto { Products = listings };
        var json = JsonSerializer.Serialize(payload);
        using var requestContent = new StringContent(json, Encoding.UTF8, "application/json");

        try
        {
            using var response = await _http.PostAsync("/api/v1/admin/products", requestContent, ct);
            var body = await response.Content.ReadAsStringAsync(ct);

            if (!response.IsSuccessStatusCode)
            {
                _logger.LogError("AISyncService: sync failed ({(int)response.StatusCode}): {Body}",
                    (int)response.StatusCode, body);
                return new AiSyncResult { Attempted = listings.Count, Succeeded = false, Error = body };
            }

            _logger.LogInformation("AISyncService: sync succeeded for {Count} listings", listings.Count);
            return new AiSyncResult { Attempted = listings.Count, Succeeded = true };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "AISyncService: sync request failed");
            return new AiSyncResult { Attempted = listings.Count, Succeeded = false, Error = ex.Message };
        }
    }

    // ── DTOs mirroring ai_service schemas (app/schemas/product.py) ──
    private sealed class ProductUpsertBatchDto
    {
        public List<ProductUpsertDto> Products { get; set; } = new();
    }

    private sealed class ProductUpsertDto
    {
        public int ProductId { get; set; }
        public int SupplierId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string Sku { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Unit { get; set; } = string.Empty;
        public double Price { get; set; }
        public double Lat { get; set; }
        public double Lon { get; set; }
        public bool InStock { get; set; }
    }
}