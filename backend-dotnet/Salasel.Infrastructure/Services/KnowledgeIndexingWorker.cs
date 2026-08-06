using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Salasel.Domain.Enums;
using Salasel.Infrastructure.Data;

namespace Salasel.Infrastructure.Services;

// Mirrors VoiceProcessingWorker's shape: drain the queue, do fake work with a
// realistic delay, write the result back. There's no real chunking/embedding
// pipeline here — this simulates one so the upload → status → ready flow is
// demoable end-to-end, same spirit as IFakeAIService for voice orders.
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

        var doc = await db.SupplierKnowledgeDocuments.FirstOrDefaultAsync(d => d.Id == job.DocumentId, ct);
        if (doc is null)
        {
            _logger.LogWarning("Knowledge document {DocumentId} no longer exists — skipping.", job.DocumentId);
            return;
        }

        _logger.LogInformation("Indexing knowledge document {DocumentId} ({FileName})", doc.Id, doc.FileName);

        var delayMs = 2000 + _rng.Next(3000);
        await Task.Delay(delayMs, ct);

        // ~90% success rate, so the Failed state / reindex flow is reachable in a demo.
        if (_rng.Next(10) == 0)
        {
            doc.Status = KnowledgeDocumentStatus.Failed;
            doc.ErrorMessage = "Simulated parsing failure — file could not be chunked.";
            doc.ChunkCount = null;
            doc.IndexedAt = null;
        }
        else
        {
            doc.Status = KnowledgeDocumentStatus.Indexed;
            doc.ChunkCount = 5 + _rng.Next(40);
            doc.ErrorMessage = null;
            doc.IndexedAt = DateTime.UtcNow;
        }

        await db.SaveChangesAsync(ct);

        _logger.LogInformation(
            "Knowledge document {DocumentId} finished with status {Status}", doc.Id, doc.Status);
    }
}