using Salasel.Application.DTOs;

namespace Salasel.Application.Interfaces;

public interface IProcurementService
{
    Task<int> LogVoiceProcurementAsync(VoiceProcurementRequestDto request);
}

public interface IOrderExecutionService
{
    Task<int> ExecuteOrderAsync(OrderExecutionRequestDto request);
}

public interface IOrderQueryService
{
    Task<OrderSummaryDto> GetOrderSummaryAsync(int merchantId);
    Task<OrderDetailDto> GetOrderByIdAsync(int orderId);
}

public interface IInventoryService
{
    Task<InventoryListResultDto> GetInventoryListAsync(int merchantId, string? category, string? q, string? status);
    Task<InventoryItemDetailDto?> GetInventoryItemAsync(int inventoryId);
    Task<InventoryItemDetailDto?> UpdateInventoryItemAsync(int inventoryId, UpdateInventoryItemDto request);
    Task<InventoryItemDetailDto?> UpdateQuantityAsync(int inventoryId, UpdateInventoryQuantityDto request);
    Task<ReorderResultDto> ReorderAsync(int inventoryId, ReorderRequestDto request);
    Task<List<InventoryAlertDto>> GetAlertsAsync(int merchantId);
    Task<bool> DismissAlertAsync(int inventoryId);
    Task<ReorderResultDto> AddAlertToOrderAsync(int inventoryId);
}

public interface IMerchantDashboardService
{
    Task<MerchantDashboardDto> GetDashboardAsync(int merchantId);
    Task<List<RecentOrderDto>> GetRecentOrdersAsync(int merchantId, int take = 10);
}

public interface ICatalogService
{
    Task<int> UploadCatalogAsync(CatalogUploadRequestDto request);
}

public interface IBiddingService
{
    // Needed so a Bidding-status, unassigned SubOrder can exist at all —
    // see CreateRfqDto for why this had to be added.
    Task<int> CreateRfqAsync(CreateRfqDto request);

    Task<KanbanResponseDto> GetKanbanAsync(int supplierId);
    Task<BidDto> SubmitBidAsync(int subOrderId, int supplierId, SubmitBidDto request);
    Task<List<BidDto>> GetBidsAsync(int masterOrderId);
    Task<BidDto> AcceptBidAsync(int masterOrderId, int bidId);
    Task UpdateRfqStatusAsync(int subOrderId, int supplierId, string status);
}
