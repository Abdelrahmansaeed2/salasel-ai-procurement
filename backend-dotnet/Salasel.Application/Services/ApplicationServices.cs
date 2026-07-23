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
            MerchantID = request.MerchantID,
            RawAudioURL = request.RawAudioURL,
            TranscribedAmiyaText = request.TranscribedAmiyaText,
            LLMParsedJSON = request.LLMParsedJSON,
            NLPConfidenceScore = request.NLPConfidenceScore,
            ProcessedAt = DateTime.UtcNow
        };

        await _voiceLogRepository.AddAsync(log);
        await _voiceLogRepository.SaveChangesAsync();

        return log.LogID;
    }
}

public class OrderExecutionService : IOrderExecutionService
{
    private readonly IRepository<OrderTransaction> _orderRepository;
    private readonly IFraudPreventionLimitRepository _fraudLimitRepository;

    public OrderExecutionService(
        IRepository<OrderTransaction> orderRepository,
        IFraudPreventionLimitRepository fraudLimitRepository)
    {
        _orderRepository = orderRepository;
        _fraudLimitRepository = fraudLimitRepository;
    }

    public async Task<int> ExecuteOrderAsync(OrderExecutionRequestDto request)
    {
        var approvalStatus = await DetermineApprovalStatusAsync(request);

        var order = new OrderTransaction
        {
            MerchantID = request.MerchantID,
            VoiceLogID = request.VoiceLogID,
            TotalOrderCost = request.TotalOrderCost,
            ApprovalStatus = approvalStatus,
            CreatedAt = DateTime.UtcNow
        };

        foreach (var splitDto in request.Splits)
        {
            order.OrderSplits.Add(new OrderSplit
            {
                SupplierID = splitDto.SupplierID,
                SKU = splitDto.SKU,
                QuantityOrdered = splitDto.QuantityOrdered,
                SubTotalCost = splitDto.SubTotalCost,
                FulfillmentStatus = FulfillmentStatus.Pending_Supplier
            });
        }

        await _orderRepository.AddAsync(order);
        await _orderRepository.SaveChangesAsync();

        return order.OrderID;
    }

    private async Task<ApprovalStatus> DetermineApprovalStatusAsync(OrderExecutionRequestDto request)
    {
        var maxOrderValueRule = await _fraudLimitRepository.GetActiveByTypeAsync(RuleType.MaxOrderValue);
        if (maxOrderValueRule != null && request.TotalOrderCost > maxOrderValueRule.HardLimitValue)
        {
            return ApprovalStatus.Fraud_Flagged;
        }

        var maxQuantityRule = await _fraudLimitRepository.GetActiveByTypeAsync(RuleType.MaxQuantityPerSKU);
        if (maxQuantityRule != null && request.Splits.Any(s => s.QuantityOrdered > maxQuantityRule.HardLimitValue))
        {
            return ApprovalStatus.Fraud_Flagged;
        }

        return ApprovalStatus.AI_Draft;
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
                i.SKU,
                i.CurrentQuantity,
                i.ReorderThreshold,
                NeedsReorder = i.CurrentQuantity <= i.ReorderThreshold,
                i.LastUpdated
            })
        };
    }
}

public class CatalogService : ICatalogService
{
    private readonly IRepository<SupplierCatalog> _catalogRepository;

    public CatalogService(IRepository<SupplierCatalog> catalogRepository)
    {
        _catalogRepository = catalogRepository;
    }

    public async Task<int> UploadCatalogAsync(CatalogUploadRequestDto request)
    {
        var existing = (await _catalogRepository.FindAsync(
            c => c.SupplierID == request.SupplierID && c.SKU == request.SKU)).SingleOrDefault();

        if (existing != null)
        {
            existing.ProductName = request.ProductName;
            existing.UnitPrice = request.UnitPrice;
            existing.StockAvailable = request.StockAvailable;
            existing.DeliveryLeadTime_Days = request.DeliveryLeadTime_Days;
            existing.VectorEmbedding = request.VectorEmbedding;
            existing.UpdatedAt = DateTime.UtcNow;

            await _catalogRepository.UpdateAsync(existing);
            await _catalogRepository.SaveChangesAsync();

            return existing.CatalogID;
        }

        var catalogItem = new SupplierCatalog
        {
            SupplierID = request.SupplierID,
            SKU = request.SKU,
            ProductName = request.ProductName,
            UnitPrice = request.UnitPrice,
            StockAvailable = request.StockAvailable,
            DeliveryLeadTime_Days = request.DeliveryLeadTime_Days,
            VectorEmbedding = request.VectorEmbedding,
            UpdatedAt = DateTime.UtcNow
        };

        await _catalogRepository.AddAsync(catalogItem);
        await _catalogRepository.SaveChangesAsync();

        return catalogItem.CatalogID;
    }
}