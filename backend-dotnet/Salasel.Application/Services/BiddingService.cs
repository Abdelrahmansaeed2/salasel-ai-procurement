using Microsoft.EntityFrameworkCore; // Include()/ThenInclude() on IQueryable
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Domain.Enums;
using Salasel.Domain.Interfaces;
using System.Net.NetworkInformation;
using System.Security.Cryptography;

namespace Salasel.Application.Services;

public class BiddingService : IBiddingService
{
    private readonly IRepository<SubOrder> _subOrderRepository;
    private readonly IRepository<Bid> _bidRepository;
    private readonly IRepository<MasterOrder> _masterOrderRepository;
    private readonly IRepository<SupplierProfile> _supplierRepository;
    private readonly IRepository<MerchantsProfile> _merchantRepository;
    private readonly IRepository<Product> _productRepository;

    public BiddingService(
        IRepository<SubOrder> subOrderRepository,
        IRepository<Bid> bidRepository,
        IRepository<MasterOrder> masterOrderRepository,
        IRepository<SupplierProfile> supplierRepository,
        IRepository<MerchantsProfile> merchantRepository,
        IRepository<Product> productRepository)
    {
        _subOrderRepository = subOrderRepository;
        _bidRepository = bidRepository;
        _masterOrderRepository = masterOrderRepository;
        _supplierRepository = supplierRepository;
        _merchantRepository = merchantRepository;
        _productRepository = productRepository;
    }

    // ─────────────────────────────── RFQ creation ───────────────────────────
    // Nothing else in the pipeline creates a Bidding-status, unassigned
    // SubOrder — voice orders always auto-assign one supplier immediately.
    // This is the merchant-initiated "ask multiple suppliers to quote" path.
    public async Task<int> CreateRfqAsync(CreateRfqDto request)
    {
        var merchant = await _merchantRepository.GetByIdAsync(request.MerchantId);
        if (merchant == null)
            throw new KeyNotFoundException($"Merchant {request.MerchantId} not found.");

        var product = await _productRepository.GetByIdAsync(request.ProductId);
        if (product == null)
            throw new KeyNotFoundException($"Product {request.ProductId} not found.");

        if (request.Quantity <= 0)
            throw new InvalidOperationException("Quantity must be greater than zero.");

        var order = new MasterOrder
        {
            MerchantId = request.MerchantId,
            TotalAmount = 0,
            Status = ApprovalStatus.Pending_Approval,
            Source = OrderSource.Manual,
            Notes = request.Notes,
            OrderDate = DateTime.UtcNow
        };

        order.SubOrders.Add(new SubOrder
        {
            ProductId = request.ProductId,
            Quantity = request.Quantity,
            SubTotalAmount = 0,
            Status = FulfillmentStatus.Bidding,
            SupplierId = null,
            CreatedAt = DateTime.UtcNow
        });

        await _masterOrderRepository.AddAsync(order);
        await _masterOrderRepository.SaveChangesAsync();

        return order.Id;
    }

    // ────────────────────────────────── Kanban ───────────────────────────────

    public async Task<KanbanResponseDto> GetKanbanAsync(int supplierId)
    {
        var relevant = await _subOrderRepository.Query()
            .Include(s => s.MasterOrder).ThenInclude(m => m.Merchant)
            .Include(s => s.Product)
            .Include(s => s.Bids)
            .Where(s =>
                (s.Status == FulfillmentStatus.Bidding && (s.SupplierId == null || s.Bids.Any(b => b.SupplierId == supplierId)))
                || s.SupplierId == supplierId)
            .ToListAsync();

        var pending = relevant
            .Where(s => s.Status == FulfillmentStatus.Bidding && s.SupplierId == null
                        && !s.Bids.Any(b => b.SupplierId == supplierId))
            .Select(s => MapCard(s, myBidPrice: null))
            .ToList();

        var bidding = relevant
            .Where(s => s.Status == FulfillmentStatus.Bidding
                        && s.Bids.Any(b => b.SupplierId == supplierId && b.Status == BidStatus.Submitted))
            .Select(s =>
            {
                var myBid = s.Bids.First(b => b.SupplierId == supplierId && b.Status == BidStatus.Submitted);
                return MapCard(s, myBid.Price);
            })
            .ToList();

        var accepted = relevant
            .Where(s => s.SupplierId == supplierId
                        && (s.Status == FulfillmentStatus.Accepted || s.Status == FulfillmentStatus.Shipped))
            .Select(s => MapCard(s, myBidPrice: null))
            .ToList();

        var delivered = relevant
            .Where(s => s.SupplierId == supplierId
                        && (s.Status == FulfillmentStatus.Delivered || s.Status == FulfillmentStatus.ReceiptConfirmed))
            .Select(s => MapCard(s, myBidPrice: null))
            .ToList();

        var rejected = relevant
            .Where(s => (s.SupplierId == supplierId && s.Status == FulfillmentStatus.Cancelled)
                        || s.Bids.Any(b => b.SupplierId == supplierId && b.Status == BidStatus.Rejected))
            .Select(s => MapCard(s, myBidPrice: null))
            .ToList();

        return new KanbanResponseDto
        {
            Columns = new List<KanbanColumnDto>
            {
                new() { Key = "Pending", Label = "طلبات جديدة", Cards = pending },
                new() { Key = "Bidding", Label = "عروضي المقدمة", Cards = bidding },
                new() { Key = "Accepted", Label = "قيد التنفيذ", Cards = accepted },
                new() { Key = "Delivered", Label = "تم التسليم", Cards = delivered },
                new() { Key = "Rejected", Label = "مرفوض", Cards = rejected }
            }
        };
    }

    public async Task<List<SupplierOrderFeedDto>> GetSupplierOrdersFeedAsync(int supplierId)
    {
        var relevant = await _subOrderRepository.Query()
            .Include(s => s.MasterOrder).ThenInclude(m => m.Merchant)
            .Include(s => s.Product)
            .Where(s => s.SupplierId == supplierId || (s.Status == FulfillmentStatus.Bidding && s.SupplierId == null))
            .OrderByDescending(s => s.CreatedAt)
            .ToListAsync();

        return relevant.Select(s => new SupplierOrderFeedDto
        {
            Id = $"ORD-{s.MasterId}-{s.Id}",
            Merchant = s.MasterOrder.Merchant?.ShopName ?? "Unknown",
            Priority = s.Status == FulfillmentStatus.Bidding ? "urgent" : "review",
            PriorityLabel = s.Status == FulfillmentStatus.Bidding ? "عاجل" : "للمراجعة",
            Confidence = 95,
            ConfidenceColor = s.Status == FulfillmentStatus.Bidding ? "#2563EB" : "#10B981",
            Total = s.SubTotalAmount.ToString("F2"),
            Items = new List<SupplierOrderFeedItemDto>
            {
                new() { Label = $"{s.Quantity}x {s.Product?.Name ?? "Product"}", Price = s.SubTotalAmount.ToString("F2") }
            }
        }).ToList();
    }

    private static KanbanCardDto MapCard(SubOrder s, decimal? myBidPrice)
    {
        var total = myBidPrice ?? s.SubTotalAmount;
        return new KanbanCardDto
        {
            Id = $"SUB-{s.Id}",
            Merchant = s.MasterOrder.Merchant?.ShopName ?? "Unknown",
            Total = total.ToString("F2"),
            ProductName = s.Product?.Name,
            Quantity = s.Quantity,
            Status = s.Status.ToString()
        };
    }

    // ───────────────────────────────── Bids ──────────────────────────────────

    public async Task<BidDto> SubmitBidAsync(int subOrderId, int supplierId, SubmitBidDto request)
    {
        if (request.Price <= 0)
            throw new InvalidOperationException("Bid price must be greater than zero.");

        var subOrder = await _subOrderRepository.GetByIdAsync(subOrderId);
        if (subOrder == null)
            throw new KeyNotFoundException($"RFQ {subOrderId} not found.");

        if (subOrder.Status != FulfillmentStatus.Bidding || subOrder.SupplierId != null)
            throw new InvalidOperationException($"This RFQ is not open for bidding (current status: {subOrder.Status}).");

        var supplier = await _supplierRepository.GetByIdAsync(supplierId);
        if (supplier == null)
            throw new KeyNotFoundException($"Supplier {supplierId} not found.");

        // Resubmitting updates the existing open bid rather than creating a duplicate.
        var existingBid = await _bidRepository.SingleOrDefaultAsync(
            b => b.SubOrderId == subOrderId && b.SupplierId == supplierId && b.Status == BidStatus.Submitted);

        if (existingBid != null)
        {
            existingBid.Price = request.Price;
            existingBid.Notes = request.Notes;
            existingBid.SubmittedAt = DateTime.UtcNow;
            await _bidRepository.UpdateAsync(existingBid);
            await _bidRepository.SaveChangesAsync();
            return MapBid(existingBid, supplier.CompanyName);
        }

        var bid = new Bid
        {
            SubOrderId = subOrderId,
            SupplierId = supplierId,
            Price = request.Price,
            Notes = request.Notes,
            Status = BidStatus.Submitted,
            SubmittedAt = DateTime.UtcNow
        };

        await _bidRepository.AddAsync(bid);
        await _bidRepository.SaveChangesAsync();

        return MapBid(bid, supplier.CompanyName);
    }

    public async Task<List<BidDto>> GetBidsAsync(int masterOrderId)
    {
        var bids = await _bidRepository.Query()
            .Include(b => b.Supplier)
            .Where(b => b.SubOrder.MasterId == masterOrderId)
            .OrderBy(b => b.Price)
            .ToListAsync();

        return bids.Select(b => MapBid(b, b.Supplier.CompanyName)).ToList();
    }

    public async Task<BidDto> AcceptBidAsync(int masterOrderId, int bidId)
    {
        var bid = await _bidRepository.GetByIdAsync(bidId);
        if (bid == null)
            throw new KeyNotFoundException($"Bid {bidId} not found.");

        var subOrder = await _subOrderRepository.GetByIdAsync(bid.SubOrderId);
        if (subOrder == null || subOrder.MasterId != masterOrderId)
            throw new InvalidOperationException("This bid does not belong to the specified order.");

        if (subOrder.Status != FulfillmentStatus.Bidding)
            throw new InvalidOperationException($"This RFQ is no longer open for bidding (current status: {subOrder.Status}).");

        if (bid.Status != BidStatus.Submitted)
            throw new InvalidOperationException("This bid is no longer available (already decided).");

        var now = DateTime.UtcNow;

        // Finalize the winning bid onto the SubOrder.
        subOrder.SupplierId = bid.SupplierId;
        subOrder.SubTotalAmount = bid.Price;
        subOrder.Status = FulfillmentStatus.Accepted;
        subOrder.AcceptedAt = now;
        subOrder.UpdatedAt = now;
        await _subOrderRepository.UpdateAsync(subOrder);

        bid.Status = BidStatus.Accepted;
        bid.DecidedAt = now;
        await _bidRepository.UpdateAsync(bid);

        // Every other open bid on this line loses.
        var otherBids = await _bidRepository.FindAsync(
            b => b.SubOrderId == subOrder.Id && b.Id != bid.Id && b.Status == BidStatus.Submitted);
        foreach (var loser in otherBids)
        {
            loser.Status = BidStatus.Rejected;
            loser.DecidedAt = now;
            await _bidRepository.UpdateAsync(loser);
        }

        var master = await _masterOrderRepository.GetByIdAsync(masterOrderId);
        if (master != null)
        {
            var siblingSubOrders = await _subOrderRepository.FindAsync(s => s.MasterId == masterOrderId);
            master.TotalAmount = siblingSubOrders.Sum(s => s.SubTotalAmount);
            master.Status = ApprovalStatus.Manually_Approved;
            master.UpdatedAt = now;
            await _masterOrderRepository.UpdateAsync(master);
        }

        await _bidRepository.SaveChangesAsync();

        var supplier = await _supplierRepository.GetByIdAsync(bid.SupplierId);
        return MapBid(bid, supplier?.CompanyName ?? string.Empty);
    }

    private static BidDto MapBid(Bid b, string supplierName) => new()
    {
        Id = b.Id,
        SubOrderId = b.SubOrderId,
        SupplierId = b.SupplierId,
        SupplierName = supplierName,
        Price = b.Price,
        Notes = b.Notes,
        Status = b.Status.ToString(),
        SubmittedAt = b.SubmittedAt
    };

    // ─────────────────────────── Drag-drop status ────────────────────────────
    // Deliberately narrow: only the two forward steps a supplier can make from
    // their own kanban board once they've won the bid. ReceiptConfirmed stays
    // merchant-only (see VoiceOrdersController.ConfirmReceipt).

    public async Task UpdateRfqStatusAsync(int subOrderId, int supplierId, string status)
    {
        var subOrder = await _subOrderRepository.Query()
            .Include(s => s.MasterOrder)
            .FirstOrDefaultAsync(s => s.Id == subOrderId);

        if (subOrder == null)
            throw new KeyNotFoundException($"RFQ {subOrderId} not found.");

        if (subOrder.SupplierId != supplierId)
            throw new UnauthorizedAccessException("This RFQ is not assigned to you.");

        if (!Enum.TryParse<FulfillmentStatus>(status, ignoreCase: true, out var target))
            throw new InvalidOperationException($"Unknown status '{status}'.");

        if (subOrder.Status == target) return;

        var now = DateTime.UtcNow;
        var valid = (subOrder.Status, target) switch
        {
            (FulfillmentStatus.Pending_Supplier, FulfillmentStatus.Accepted) => true,
            (FulfillmentStatus.Pending_Supplier, FulfillmentStatus.Cancelled) => true, // Supplier rejects
            (FulfillmentStatus.Accepted, FulfillmentStatus.Shipped) => true,
            (FulfillmentStatus.Shipped, FulfillmentStatus.Delivered) => true,
            _ => false
        };

        if (!valid)
            throw new InvalidOperationException($"Cannot move from {subOrder.Status} to {target} here.");

        subOrder.Status = target;
        subOrder.UpdatedAt = now;
        if (target == FulfillmentStatus.Shipped) subOrder.ShippedAt = now;
        if (target == FulfillmentStatus.Delivered) subOrder.DeliveredAt = now;

        // Sync MasterOrder status to show in Merchant Mobile app
        if (target == FulfillmentStatus.Accepted && subOrder.MasterOrder != null && subOrder.MasterOrder.Status == ApprovalStatus.Pending_Approval)
        {
            subOrder.MasterOrder.Status = ApprovalStatus.Manually_Approved;
            subOrder.MasterOrder.UpdatedAt = now;
        }

        await _subOrderRepository.UpdateAsync(subOrder);
        await _subOrderRepository.SaveChangesAsync();
    }
}
