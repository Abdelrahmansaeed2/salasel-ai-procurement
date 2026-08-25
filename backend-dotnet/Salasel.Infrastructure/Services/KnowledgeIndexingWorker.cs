using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Salasel.Domain.Enums;
using Salasel.Infrastructure.Data;
using System.IO;

namespace Salasel.Infrastructure.Services;

// Mirrors VoiceProcessingWorker's shape: drain the queue, do fake work with a
// realistic delay, write the result back. There's no real chunking/embedding
// pipeline here — this simulates one so the upload → status → ready flow is
// demoable end-to-end.
public class KnowledgeIndexingWorker : BackgroundService
{
    private readonly IKnowledgeIndexingQueue _queue;
    private readonly IServiceProvider _services;
    private readonly ILogger<KnowledgeIndexingWorker> _logger;
    private static readonly Random _rng = new();

    public KnowledgeIndexingWorker(
        IKnowledgeIndexingQueue queue,
        IServiceProvider services,
        ILogger<KnowledgeIndexingWorker> logger)
    {
        _queue = queue;
        _services = services;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        await foreach (var job in _queue.DequeueAllAsync(stoppingToken))
        {
            try
            {
                await ProcessAsync(job, stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to index knowledge document {DocumentId}", job.DocumentId);
            }
        }
    }

    private async Task ProcessAsync(KnowledgeIndexingJob job, CancellationToken ct)
    {
        using var scope = _services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<SalaselDbContext>();
        var aiService = scope.ServiceProvider.GetRequiredService<IAIService>();

        var doc = await db.SupplierKnowledgeDocuments.FirstOrDefaultAsync(d => d.Id == job.DocumentId, ct);
        if (doc is null)
        {
            _logger.LogWarning("Knowledge document {DocumentId} no longer exists — skipping.", job.DocumentId);
            return;
        }

        _logger.LogInformation("Indexing knowledge document {DocumentId} ({FileName})", doc.Id, doc.FileName);

        var webRoot = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
        var filePath = Path.Combine(webRoot, doc.FileUrl.TrimStart('/', '\\'));

        if (!File.Exists(filePath))
        {
            doc.Status = KnowledgeDocumentStatus.Failed;
            doc.ErrorMessage = "File not found on disk.";
            await db.SaveChangesAsync(ct);
            return;
        }

        try
        {
            var warehouse = await db.SupplierWarehouses.FirstOrDefaultAsync(w => w.SupplierId == doc.SupplierId, ct);
            double lat = warehouse != null ? (double)warehouse.Lat : 0;
            double lon = warehouse != null ? (double)warehouse.Lng : 0;

            var response = await aiService.IngestKnowledgeAsync(doc.SupplierId, filePath, doc.FileName, lat, lon, ct);
            if (response.IsSuccess)
            {
                doc.Status = KnowledgeDocumentStatus.Indexed;
                doc.ChunkCount = 50; // default for demo
                doc.ErrorMessage = null;
                doc.IndexedAt = DateTime.UtcNow;

                // For the presentation mockup: Automatically seed the SQL database
                // so the user can immediately see the extracted products in the Catalog.
                try 
                {
                    await SeedCsvToCatalogAsync(db, doc.SupplierId, filePath, ct);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Failed to automatically seed catalog from CSV.");
                }
            }
            else
            {
                doc.Status = KnowledgeDocumentStatus.Failed;
                doc.ErrorMessage = $"AI service returned {response.StatusCode}: {response.Body}";
            }
        }
        catch (Exception ex)
        {
            doc.Status = KnowledgeDocumentStatus.Failed;
            doc.ErrorMessage = $"Error calling AI service: {ex.Message}";
        }

        await db.SaveChangesAsync(ct);

        _logger.LogInformation(
            "Knowledge document {DocumentId} finished with status {Status}", doc.Id, doc.Status);
    }

    private async Task SeedCsvToCatalogAsync(SalaselDbContext db, int supplierId, string filePath, CancellationToken ct)
    {
        if (!filePath.EndsWith(".csv", StringComparison.OrdinalIgnoreCase)) return;

        var lines = await File.ReadAllLinesAsync(filePath, ct);
        if (lines.Length <= 1) return; // Empty or just header

        // Ensure a dummy category exists
        var category = await db.Categories.FirstOrDefaultAsync(c => c.Name == "General", ct);
        if (category == null)
        {
            category = new Salasel.Domain.Entities.Category { Name = "General" };
            db.Categories.Add(category);
            await db.SaveChangesAsync(ct);
        }

        foreach (var line in lines.Skip(1))
        {
            if (string.IsNullOrWhiteSpace(line)) continue;
            
            var cols = line.Split(',');
            if (cols.Length < 6) continue;

            string sku = cols[0].Trim();
            string name = cols[1].Trim().Trim('"');
            string unit = cols[3].Trim();
            decimal price = decimal.TryParse(cols[4], out var p) ? p : 0;
            int stock = int.TryParse(cols[5], out var s) ? s : 0;

            var product = await db.Products.FirstOrDefaultAsync(p => p.SKU == sku, ct);
            if (product == null)
            {
                product = new Salasel.Domain.Entities.Product
                {
                    SKU = sku,
                    Name = name,
                    Unit = unit,
                    CategoryId = category.Id,
                    IsActive = true
                };
                db.Products.Add(product);
                await db.SaveChangesAsync(ct); // Save to get the generated Id
            }

            var sp = await db.SupplierProducts.FirstOrDefaultAsync(x => x.SupplierId == supplierId && x.ProductId == product.Id, ct);
            if (sp == null)
            {
                sp = new Salasel.Domain.Entities.SupplierProduct
                {
                    SupplierId = supplierId,
                    ProductId = product.Id,
                    UnitPrice = price,
                    AvailableQty = stock,
                    MinOrderQty = 1,
                    LeadTimeDays = 1,
                    IsActive = true
                };
                db.SupplierProducts.Add(sp);
            }
            else
            {
                sp.UnitPrice = price;
                sp.AvailableQty = stock;
            }
        }
        await db.SaveChangesAsync(ct);
    }
}