using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Domain.Enums;
using Salasel.Domain.Interfaces;

namespace Salasel.Application.Services;

public class ProcurementService : IProcurementService
{
    private readonly IRepository<VoiceProcurementLog> _voiceLogRepository;

    public ProcurementService(IRepository<VoiceProcurementLog> voiceLogRepository)
    {
        _voiceLogRepository = voiceLogRepository;
    }

    public async Task<int> LogVoiceProcurementAsync(VoiceProcurementRequestDto request)
    {
        var log = new VoiceProcurementLog
        {
            MerchantId = request.MerchantID,
            AudioUrl = request.RawAudioURL,
            Transcript = request.TranscribedAmiyaText,
            CreatedAt = DateTime.UtcNow,
            AIProcessing = new AIProcessing 
            {
                ParsedJson = request.LLMParsedJSON,
                Confidence = request.NLPConfidenceScore
            }
        };

        await _voiceLogRepository.AddAsync(log);
        await _voiceLogRepository.SaveChangesAsync();

        return log.Id;
    }
}

public class OrderExecutionService : IOrderExecutionService
{
    private readonly IRepository<MasterOrder> _orderRepository;

    public OrderExecutionService(IRepository<MasterOrder> orderRepository)
    {
        _orderRepository = orderRepository;
    }

    public async Task<int> ExecuteOrderAsync(OrderExecutionRequestDto request)
    {
        var approvalStatus = ApprovalStatus.AI_Draft;

        var order = new MasterOrder
        {
            MerchantId = request.MerchantID,
            VoiceLogID = request.VoiceLogID,
            TotalAmount = request.TotalOrderCost,
            Status = approvalStatus,
            OrderDate = DateTime.UtcNow
        };

        foreach (var splitDto in request.Splits)
        {
            order.SubOrders.Add(new SubOrder
            {
                SupplierId = splitDto.SupplierID,
                Status = FulfillmentStatus.Pending_Supplier
            });
        }

        await _orderRepository.AddAsync(order);
        await _orderRepository.SaveChangesAsync();

        return order.Id;
    }
}

public class InventoryService : IInventoryService
{
    private readonly IRepository<MerchantInventory> _inventoryRepository;

    public InventoryService(IRepository<MerchantInventory> inventoryRepository)
    {
        _inventoryRepository = inventoryRepository;
    }

    public async Task<object> GetInventoryStatusAsync(int merchantId)
    {
        var items = await _inventoryRepository.FindAsync(i => i.MerchantID == merchantId);

        return new
        {
            MerchantID = merchantId,
            Items = items.Select(i => new
            {
                i.InventoryID,
                i.ProductId,
                i.CurrentQty,
                i.LastUpdated
            })
        };
    }
}

public class CatalogService : ICatalogService
{
    private readonly IRepository<SupplierProduct> _catalogRepository;

    public CatalogService(IRepository<SupplierProduct> catalogRepository)
    {
        _catalogRepository = catalogRepository;
    }

    public async Task<int> UploadCatalogAsync(CatalogUploadRequestDto request)
    {
        var catalogItem = new SupplierProduct
        {
            SupplierId = request.SupplierID,
            UnitPrice = request.UnitPrice,
            LastUpdated = DateTime.UtcNow
        };

        await _catalogRepository.AddAsync(catalogItem);
        await _catalogRepository.SaveChangesAsync();

        return catalogItem.Id;
    }
}
