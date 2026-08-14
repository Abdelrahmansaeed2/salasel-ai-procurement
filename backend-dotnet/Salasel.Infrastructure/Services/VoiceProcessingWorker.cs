using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Hosting;
using Salasel.Domain.Entities;
using Salasel.Domain.Enums;
using Salasel.Infrastructure.Data;
using Salasel.Infrastructure.Models;

namespace Salasel.Infrastructure.Services;

public class VoiceProcessingWorker : BackgroundService
{
    private readonly IBackgroundQueue _queue;
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly IWebHostEnvironment _env;
    private readonly ILogger<VoiceProcessingWorker> _logger;

    public VoiceProcessingWorker(
        IBackgroundQueue queue,
        IServiceScopeFactory scopeFactory,
        IWebHostEnvironment env,
        ILogger<VoiceProcessingWorker> logger)
    {
        _queue = queue;
        _scopeFactory = scopeFactory;
        _env = env;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("VoiceProcessingWorker started.");

        await foreach (var job in _queue.DequeueAllAsync(stoppingToken))
        {
            try
            {
                await ProcessJobAsync(job, stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to process voice upload {Id}", job.VoiceLogId);
            }
        }
    }

    private async Task ProcessJobAsync(VoiceProcessingJob job, CancellationToken ct)
    {
        using var scope = _scopeFactory.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<SalaselDbContext>();
        var ai = scope.ServiceProvider.GetRequiredService<IAIService>();
        var supplierAssignment = scope.ServiceProvider.GetRequiredService<ISupplierAssignmentService>();
        var notifications = scope.ServiceProvider.GetRequiredService<INotificationService>();

        var voiceLog = await db.VoiceProcurementLogs.FindAsync(new object[] { job.VoiceLogId }, ct);
        if (voiceLog is null)
        {
            _logger.LogWarning("VoiceProcurementLog {Id} not found", job.VoiceLogId);
            return;
        }

        var merchant = await db.MerchantsProfiles
            .FirstOrDefaultAsync(m => m.MerchantID == job.MerchantId, ct);
        if (merchant == null)
            throw new InvalidOperationException($"Merchant {job.MerchantId} not found.");

        var webRoot = string.IsNullOrEmpty(_env.WebRootPath)
            ? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot")
            : _env.WebRootPath;

        var absoluteFilePath = PathHelpers.ToAbsolute(job.FilePath, webRoot);

        try
        {
            var stopwatch = System.Diagnostics.Stopwatch.StartNew();
            var aiResult = await ai.ProcessVoiceAsync(
                absoluteFilePath,
                job.MerchantId,
                (double)merchant.LocationLat,
                (double)merchant.LocationLng,
                ct);
            stopwatch.Stop();

            // ai_service returns SKU-level splits; resolve SKU -> product name for a
            // human-readable draft (SKU is unique on Product). Unknown SKUs keep the raw value.
            aiResult = await EnrichProductNamesAsync(db, aiResult, ct);

            // Assign the AI's preferred (dominant) supplier, falling back to the
            // nearest routed supplier when the AI returned no usable split.
            int? supplierId = aiResult.PreferredSupplierId;
            if (supplierId is null || !await db.SupplierProfiles.AnyAsync(s => s.SupplierID == supplierId, ct))
                supplierId = await supplierAssignment.GetNearestSupplierAsync(job.MerchantId, ct);
            if (supplierId is 0)
                supplierId = null;

            var total = aiResult.TotalOrderCost > 0 ? aiResult.TotalOrderCost
                                                    : aiResult.Items.Sum(i => i.Quantity * i.Price);
            var totalQty = aiResult.Items.Sum(i => i.Quantity);

            // Persist AI result
            var aiProcessing = new AIProcessing
            {
                VoiceLogId = voiceLog.Id,
                ModelUsed = aiResult.ModelUsed ?? "ai_service",
                Prompt = "voice-order-extraction",
                ParsedJson = JsonSerializer.Serialize(aiResult),
                Confidence = 0.85m,
                ProcessingDurationMs = (int)stopwatch.ElapsedMilliseconds,
                CreatedAt = DateTime.UtcNow
            };
            db.AIProcessings.Add(aiProcessing);

            // Master order (draft) + one sub-order for nearest supplier
            var master = new MasterOrder
            {
                MerchantId = aiResult.MerchantId,
                VoiceLogID = voiceLog.Id,
                TotalAmount = total,
                Status = ApprovalStatus.AI_Draft,
                Source = OrderSource.Voice,
                Notes = $"Voice draft from log #{voiceLog.Id}",
                OrderDate = DateTime.UtcNow,
                SubOrders = new List<SubOrder>
                {
                    new SubOrder
                    {
                        SupplierId = supplierId,
                        Quantity = totalQty,
                        SubTotalAmount = total,
                        Status = FulfillmentStatus.Pending_Supplier,
                        CreatedAt = DateTime.UtcNow
                    }
                }
            };

            db.MasterOrders.Add(master);
            await db.SaveChangesAsync(ct);

            // Reload navigations for payload
            await db.Entry(master).Reference(o => o.Merchant).LoadAsync(ct);
            await db.Entry(master).Collection(o => o.SubOrders).LoadAsync(ct);
            foreach (var so in master.SubOrders)
                await db.Entry(so).Reference(s => s.Supplier).LoadAsync(ct);

            var payload = OrderMapper.Map(master, aiResult);

            await notifications.NotifyMerchantAsync(
                master.MerchantId,
                "DraftOrderReady",
                payload,
                ct);

            _logger.LogInformation(
                "Draft master order {OrderId} created and merchant notified.",
                master.Id);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "AI processing failed for voice log {VoiceLogId}", job.VoiceLogId);

            await notifications.NotifyMerchantAsync(
                job.MerchantId,
                "ProcessingFailed",
                new { uploadId = job.VoiceLogId, reason = ex.Message },
                ct);

            throw;
        }
    }

    private async Task<AiOrderResult> EnrichProductNamesAsync(
        SalaselDbContext db,
        AiOrderResult aiResult,
        CancellationToken ct)
    {
        var skus = aiResult.Items.Select(i => i.ProductName).Distinct().ToList();
        if (skus.Count == 0)
            return aiResult;

        var skuToName = await db.Products
            .AsNoTracking()
            .Where(p => skus.Contains(p.SKU))
            .Select(p => new { p.SKU, p.Name })
            .ToDictionaryAsync(x => x.SKU, x => x.Name, ct);

        foreach (var item in aiResult.Items)
        {
            if (skuToName.TryGetValue(item.ProductName, out var name))
                item.ProductName = name;
        }

        return aiResult;
    }
}

public static class OrderMapper
{
    public static object Map(MasterOrder o, AiOrderResult? aiResult = null)
    {
        var sub = o.SubOrders?.FirstOrDefault();
        double? distanceKm = null;

        if (o.Merchant != null && sub?.Supplier != null)
        {
            distanceKm = GeoHelper.DistanceKm(
                (double)o.Merchant.LocationLat,
                (double)o.Merchant.LocationLng,
                (double)sub.Supplier.LocationLat,
                (double)sub.Supplier.LocationLng);
        }

        // Prefer live AI result; otherwise try parse from Notes is not ideal —
        // caller should pass aiResult when available. Items may be empty when listing.
        var items = (aiResult?.Items ?? new List<AiOrderItem>()).Select(i => new
        {
            id = i.Id,
            productName = i.ProductName,
            quantity = i.Quantity,
            price = i.Price,
            lineTotal = i.Quantity * i.Price
        });

        var status = MapStatus(o.Status, sub?.Status);

        return new
        {
            orderId = o.Id,
            merchantId = o.MerchantId,
            merchantName = o.Merchant?.ShopName,
            merchantAddress = o.Merchant?.Address,
            merchantCity = o.Merchant?.BusinessCity,

            supplierId = sub?.SupplierId,
            supplierName = sub?.Supplier?.CompanyName,

            distanceKm = distanceKm.HasValue ? (double?)Math.Round(distanceKm.Value, 2) : null,

            status,
            createdAt = o.OrderDate,
            confirmedAt = o.UpdatedAt,

            items,
            total = o.TotalAmount
        };
    }

    public static object MapWithParsedItems(MasterOrder o, string? parsedJson)
    {
        AiOrderResult? ai = null;
        if (!string.IsNullOrEmpty(parsedJson))
        {
            try
            {
                ai = JsonSerializer.Deserialize<AiOrderResult>(parsedJson, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });
            }
            catch { /* ignore bad JSON */ }
        }
        return Map(o, ai);
    }

    private static string MapStatus(ApprovalStatus approval, FulfillmentStatus? fulfillment)
    {
        return approval switch
        {
            ApprovalStatus.AI_Draft => "Draft",
            ApprovalStatus.Pending_Approval => "Confirmed",
            ApprovalStatus.Manually_Approved =>
                fulfillment == FulfillmentStatus.Accepted ? "Accepted" : "Confirmed",
            ApprovalStatus.Rejected =>
                fulfillment == FulfillmentStatus.Cancelled ? "Declined" : "Cancelled",
            _ => approval.ToString()
        };
    }
}