using System.Text.Json;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Salasel.Domain.Entities;
using Salasel.Infrastructure.Data;
using Salasel.Infrastructure.Hubs;

namespace Salasel.Infrastructure.Services;

public interface INotificationService
{
    Task NotifyMerchantAsync(int merchantId, string eventName, object payload, CancellationToken ct = default);
    Task NotifySupplierAsync(int supplierId, string eventName, object payload, CancellationToken ct = default);
}

public class NotificationService : INotificationService
{
    private readonly IHubContext<NotificationHub> _hub;
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<NotificationService> _logger;

    public NotificationService(
        IHubContext<NotificationHub> hub,
        IServiceScopeFactory scopeFactory,
        ILogger<NotificationService> logger)
    {
        _hub = hub;
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    public async Task NotifyMerchantAsync(int merchantId, string eventName, object payload, CancellationToken ct = default)
    {
        await _hub.Clients.Group($"merchant-{merchantId}").SendAsync(eventName, payload, ct);
        await PersistAsync(merchantId, isSupplier: false, eventName, payload, ct);
    }

    public async Task NotifySupplierAsync(int supplierId, string eventName, object payload, CancellationToken ct = default)
    {
        await _hub.Clients.Group($"supplier-{supplierId}").SendAsync(eventName, payload, ct);
        await PersistAsync(supplierId, isSupplier: true, eventName, payload, ct);
    }

    // This service is registered as a Singleton (it holds the long-lived
    // IHubContext), so it can't take a scoped SalaselDbContext in its
    // constructor — a fresh scope is created per call instead, same pattern
    // as VoiceProcessingWorker/KnowledgeIndexingWorker resolving DbContext.
    private async Task PersistAsync(int profileId, bool isSupplier, string eventName, object payload, CancellationToken ct)
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<SalaselDbContext>();

            int? ownerUserId = isSupplier
                ? await db.SupplierProfiles.Where(s => s.SupplierID == profileId).Select(s => (int?)s.OwnerUserId).FirstOrDefaultAsync(ct)
                : await db.MerchantsProfiles.Where(m => m.MerchantID == profileId).Select(m => (int?)m.OwnerUserId).FirstOrDefaultAsync(ct);

            if (ownerUserId is null)
            {
                _logger.LogWarning(
                    "Could not persist notification — no {Kind} profile {ProfileId} found.",
                    isSupplier ? "supplier" : "merchant", profileId);
                return;
            }

            db.Notifications.Add(new Notification
            {
                UserId = ownerUserId.Value,
                EventName = eventName,
                PayloadJson = JsonSerializer.Serialize(payload),
                IsRead = false,
                CreatedAt = DateTime.UtcNow
            });

            await db.SaveChangesAsync(ct);
        }
        catch (Exception ex)
        {
            // Never let a notification-history write break the real-time push
            // or the caller's own flow (order confirm, delivery, etc).
            _logger.LogError(ex, "Failed to persist notification {EventName} for {Kind} {ProfileId}.",
                eventName, isSupplier ? "supplier" : "merchant", profileId);
        }
    }
}