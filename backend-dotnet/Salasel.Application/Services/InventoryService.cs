using Microsoft.EntityFrameworkCore;
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Domain.Enums;
using Salasel.Domain.Interfaces;

namespace Salasel.Application.Services;

public class InventoryService : IInventoryService
{
    private readonly IRepository<MerchantInventory> _inventoryRepository;
    private readonly IRepository<SupplierProduct> _supplierProductRepository;
    private readonly IRepository<MasterOrder> _masterOrderRepository;

    public InventoryService(
        IRepository<MerchantInventory> inventoryRepository,
        IRepository<SupplierProduct> supplierProductRepository,
        IRepository<MasterOrder> masterOrderRepository)
    {
        _inventoryRepository = inventoryRepository;
        _supplierProductRepository = supplierProductRepository;
        _masterOrderRepository = masterOrderRepository;
    }

    // ─────────────────────────── List / detail ───────────────────────────

    public async Task<InventoryListResultDto> GetInventoryListAsync(int merchantId, string? category, string? q, string? status)
    {
        var query = _inventoryRepository.Query()
            .Include(i => i.Product).ThenInclude(p => p.Category)
            .Where(i => i.MerchantID == merchantId);

        if (!string.IsNullOrWhiteSpace(category))
        {
            var categoryLower = category.Trim().ToLower();
            query = query.Where(i => i.Product.Category.Name.ToLower() == categoryLower);
        }

        if (!string.IsNullOrWhiteSpace(q))
        {
            var qLower = q.Trim().ToLower();
            query = query.Where(i => i.Product.Name.ToLower().Contains(qLower)
                                      || i.Product.SKU.ToLower().Contains(qLower));
        }

        var items = (await query.ToListAsync()).Select(MapToDetailDto).ToList();

        if (!string.IsNullOrWhiteSpace(status))
        {
            items = items.Where(i => string.Equals(i.Status, status, StringComparison.OrdinalIgnoreCase)).ToList();
        }

        return new InventoryListResultDto { MerchantID = merchantId, Items = items };
    }

    public async Task<InventoryItemDetailDto?> GetInventoryItemAsync(int inventoryId)
    {
        var item = await _inventoryRepository.Query()
            .Include(i => i.Product).ThenInclude(p => p.Category)
            .FirstOrDefaultAsync(i => i.InventoryID == inventoryId);

        return item == null ? null : MapToDetailDto(item);
    }

    // ─────────────────────────────── Edits ────────────────────────────────

    public async Task<InventoryItemDetailDto?> UpdateInventoryItemAsync(int inventoryId, UpdateInventoryItemDto request)
    {
        var item = await _inventoryRepository.GetByIdAsync(inventoryId);
        if (item == null) return null;

        item.CurrentQty = request.CurrentQty;
        item.ReorderThreshold = request.ReorderThreshold;
        item.LastUpdated = DateTime.UtcNow;
        ClearStaleDismissal(item);

        await _inventoryRepository.UpdateAsync(item);
        await _inventoryRepository.SaveChangesAsync();

        return await GetInventoryItemAsync(inventoryId);
    }

    public async Task<InventoryItemDetailDto?> UpdateQuantityAsync(int inventoryId, UpdateInventoryQuantityDto request)
    {
        var item = await _inventoryRepository.GetByIdAsync(inventoryId);
        if (item == null) return null;

        item.CurrentQty = request.Quantity;
        item.LastUpdated = DateTime.UtcNow;
        ClearStaleDismissal(item);

        await _inventoryRepository.UpdateAsync(item);
        await _inventoryRepository.SaveChangesAsync();

        return await GetInventoryItemAsync(inventoryId);
    }

    // A fresh quantity change is a new "episode" — don't let a stale dismissal
    // from before this change keep suppressing the alert incorrectly.
    private static void ClearStaleDismissal(MerchantInventory item)
    {
        item.LowStockAlertDismissedAt = null;
        item.LowStockAlertDismissedAtQty = null;
    }

    // ────────────────────────────── Reorder ───────────────────────────────

    // Always creates a brand-new, standalone one-line draft order for this
    // product — the "one-tap reorder" action.
    public async Task<ReorderResultDto> ReorderAsync(int inventoryId, ReorderRequestDto request)
    {
        var item = await _inventoryRepository.GetByIdAsync(inventoryId);
        if (item == null)
            throw new KeyNotFoundException($"Inventory item {inventoryId} not found.");

        var quantity = request.Quantity ?? Math.Max(item.ReorderThreshold * 2 - item.CurrentQty, 1);
        var supplierProduct = await FindBestSupplierProductAsync(item.ProductId, quantity);

        var order = new MasterOrder
        {
            MerchantId = item.MerchantID,
            TotalAmount = supplierProduct.UnitPrice * quantity,
            Status = ApprovalStatus.AI_Draft,
            Source = OrderSource.Manual, // merchant tapped the button; not a fully automatic AI_Auto trigger
            Notes = "Created via one-tap inventory reorder.",
            OrderDate = DateTime.UtcNow
        };

        order.SubOrders.Add(new SubOrder
        {
            SupplierId = supplierProduct.SupplierId,
            ProductId = item.ProductId,
            Quantity = quantity,
            SubTotalAmount = supplierProduct.UnitPrice * quantity,
            Status = FulfillmentStatus.Pending_Supplier
        });

        await _masterOrderRepository.AddAsync(order);
        await _masterOrderRepository.SaveChangesAsync();

        return new ReorderResultDto
        {
            MasterOrderId = order.Id,
            SupplierId = supplierProduct.SupplierId,
            SupplierName = supplierProduct.Supplier.CompanyName,
            QuantityOrdered = quantity,
            SubTotalCost = supplierProduct.UnitPrice * quantity
        };
    }

    // Appends to the merchant's current draft order if one exists, otherwise
    // creates one — distinct from ReorderAsync, which always stands alone.
    public async Task<ReorderResultDto> AddAlertToOrderAsync(int inventoryId)
    {
        var item = await _inventoryRepository.GetByIdAsync(inventoryId);
        if (item == null)
            throw new KeyNotFoundException($"Inventory item {inventoryId} not found.");

        var quantity = Math.Max(item.ReorderThreshold * 2 - item.CurrentQty, 1);
        var supplierProduct = await FindBestSupplierProductAsync(item.ProductId, quantity);
        var lineTotal = supplierProduct.UnitPrice * quantity;

        var draftOrder = await _masterOrderRepository.Query()
            .Include(o => o.SubOrders)
            .Where(o => o.MerchantId == item.MerchantID && o.Status == ApprovalStatus.AI_Draft)
            .OrderByDescending(o => o.OrderDate)
            .FirstOrDefaultAsync();

        if (draftOrder == null)
        {
            draftOrder = new MasterOrder
            {
                MerchantId = item.MerchantID,
                Status = ApprovalStatus.AI_Draft,
                Source = OrderSource.Manual,
                Notes = "Created from inventory alert suggestions.",
                OrderDate = DateTime.UtcNow
            };
            await _masterOrderRepository.AddAsync(draftOrder);
        }

        draftOrder.SubOrders.Add(new SubOrder
        {
            SupplierId = supplierProduct.SupplierId,
            ProductId = item.ProductId,
            Quantity = quantity,
            SubTotalAmount = lineTotal,
            Status = FulfillmentStatus.Pending_Supplier
        });
        draftOrder.TotalAmount = draftOrder.SubOrders.Sum(s => s.SubTotalAmount);
        draftOrder.UpdatedAt = DateTime.UtcNow;

        await _masterOrderRepository.UpdateAsync(draftOrder);
        await _masterOrderRepository.SaveChangesAsync();

        return new ReorderResultDto
        {
            MasterOrderId = draftOrder.Id,
            SupplierId = supplierProduct.SupplierId,
            SupplierName = supplierProduct.Supplier.CompanyName,
            QuantityOrdered = quantity,
            SubTotalCost = lineTotal
        };
    }

    // Cheapest supplier that can cover the requested quantity; falls back to
    // the cheapest supplier for the product at all if none currently has
    // enough stock (better to place the order and let the supplier flag a
    // partial fulfillment than to block the merchant entirely).
    private async Task<SupplierProduct> FindBestSupplierProductAsync(int productId, int quantity)
    {
        var candidates = await _supplierProductRepository.Query()
            .Include(sp => sp.Supplier)
            .Where(sp => sp.ProductId == productId)
            .OrderBy(sp => sp.UnitPrice)
            .ToListAsync();

        if (candidates.Count == 0)
            throw new InvalidOperationException($"No supplier currently lists product {productId}.");

        return candidates.FirstOrDefault(sp => sp.AvailableQty >= quantity) ?? candidates[0];
    }

    // ────────────────────────────── Alerts ─────────────────────────────────

    public async Task<List<InventoryAlertDto>> GetAlertsAsync(int merchantId)
    {
        var items = await _inventoryRepository.Query()
            .Include(i => i.Product)
            .Where(i => i.MerchantID == merchantId && i.CurrentQty <= i.ReorderThreshold)
            .ToListAsync();

        return items
            .Where(i => !IsDismissed(i))
            .Select(i => new InventoryAlertDto
            {
                InventoryID = i.InventoryID,
                ProductId = i.ProductId,
                ProductName = i.Product.Name,
                SKU = i.Product.SKU,
                CurrentQty = i.CurrentQty,
                ReorderThreshold = i.ReorderThreshold,
                EstimatedDaysUntilStockOut = null // see InventoryAlertDto for why
            })
            .ToList();
    }

    private static bool IsDismissed(MerchantInventory item) =>
        item.LowStockAlertDismissedAt != null
        && item.LowStockAlertDismissedAtQty.HasValue
        && item.CurrentQty >= item.LowStockAlertDismissedAtQty.Value;

    public async Task<bool> DismissAlertAsync(int inventoryId)
    {
        var item = await _inventoryRepository.GetByIdAsync(inventoryId);
        if (item == null) return false;

        item.LowStockAlertDismissedAt = DateTime.UtcNow;
        item.LowStockAlertDismissedAtQty = item.CurrentQty;

        await _inventoryRepository.UpdateAsync(item);
        await _inventoryRepository.SaveChangesAsync();
        return true;
    }

    // ────────────────────────────── Mapping ────────────────────────────────

    private static InventoryItemDetailDto MapToDetailDto(MerchantInventory i)
    {
        var status = i.CurrentQty <= 0 ? "Out" : i.CurrentQty <= i.ReorderThreshold ? "Low" : "Ok";

        return new InventoryItemDetailDto
        {
            InventoryID = i.InventoryID,
            MerchantID = i.MerchantID,
            ProductId = i.ProductId,
            ProductName = i.Product.Name,
            SKU = i.Product.SKU,
            Unit = i.Product.Unit,
            ImageUrl = i.Product.ImageUrl,
            CategoryId = i.Product.CategoryId,
            CategoryName = i.Product.Category?.Name ?? string.Empty,
            CurrentQty = i.CurrentQty,
            ReorderThreshold = i.ReorderThreshold,
            Status = status,
            LastUpdated = i.LastUpdated
        };
    }
}
