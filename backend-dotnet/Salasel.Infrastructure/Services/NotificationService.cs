using Microsoft.AspNetCore.SignalR;
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

    public NotificationService(IHubContext<NotificationHub> hub)
    {
        _hub = hub;
    }

    public Task NotifyMerchantAsync(int merchantId, string eventName, object payload, CancellationToken ct = default) =>
        _hub.Clients.Group($"merchant-{merchantId}").SendAsync(eventName, payload, ct);

    public Task NotifySupplierAsync(int supplierId, string eventName, object payload, CancellationToken ct = default) =>
        _hub.Clients.Group($"supplier-{supplierId}").SendAsync(eventName, payload, ct);
}
