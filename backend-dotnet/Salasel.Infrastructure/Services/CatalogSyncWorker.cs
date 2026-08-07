using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Salasel.Infrastructure.Services;

/// <summary>
/// Best-effort one-shot sync of the live catalog into the ai_service Qdrant index
/// on startup. Never blocks or crashes the app: a failure is logged and the admin
/// can re-trigger via POST /api/v1/admin/ai/sync-catalog.
/// </summary>
public class CatalogSyncWorker : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<CatalogSyncWorker> _logger;

    public CatalogSyncWorker(IServiceScopeFactory scopeFactory, ILogger<CatalogSyncWorker> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        // Let the API finish booting / applying migrations first.
        await Task.Delay(TimeSpan.FromSeconds(10), stoppingToken);

        using var scope = _scopeFactory.CreateScope();
        var sync = scope.ServiceProvider.GetRequiredService<IAISyncService>();

        _logger.LogInformation("CatalogSyncWorker: starting best-effort catalog sync...");
        var result = await sync.SyncAllActiveProductsAsync(stoppingToken);

        if (result.Succeeded)
            _logger.LogInformation("CatalogSyncWorker: synced {Count} product listings.", result.Attempted);
        else
            _logger.LogWarning(
                "CatalogSyncWorker: sync failed ({Count} attempted): {Error}",
                result.Attempted, result.Error);
    }
}