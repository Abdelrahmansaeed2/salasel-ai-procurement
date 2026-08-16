using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace Salasel.Infrastructure.Hubs;

[Authorize]
public class NotificationHub : Hub
{
    public async Task JoinAsMerchant(int merchantId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"merchant-{merchantId}");
        await Groups.AddToGroupAsync(Context.ConnectionId, "merchants");
        await Clients.Caller.SendAsync("Joined", new { role = "merchant", id = merchantId });
    }

    public async Task JoinAsSupplier(int supplierId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"supplier-{supplierId}");
        await Groups.AddToGroupAsync(Context.ConnectionId, "suppliers");
        await Clients.Caller.SendAsync("Joined", new { role = "supplier", id = supplierId });
    }

    public async Task LeaveGroups(int? merchantId, int? supplierId)
    {
        if (merchantId.HasValue)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"merchant-{merchantId}");
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, "merchants");
        }
        if (supplierId.HasValue)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"supplier-{supplierId}");
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, "suppliers");
        }
    }

    public async Task JoinAsAdmin(int adminId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"admin-{adminId}");
        await Groups.AddToGroupAsync(Context.ConnectionId, "admins");
        await Clients.Caller.SendAsync("Joined", new { role = "admin", id = adminId });
    }
}
