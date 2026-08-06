using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Domain.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/search")]
[Authorize]
public class SearchController : ControllerBase
{
    private readonly IRepository<MasterOrder> _masterOrderRepository;
    private readonly IRepository<SupplierProfile> _supplierRepository;
    private readonly IMerchantProfileRepository _merchantRepository;
    private readonly ISupplierProfileRepository _myOwnSupplierRepository;

    public SearchController(
        IRepository<MasterOrder> masterOrderRepository,
        IRepository<SupplierProfile> supplierRepository,
        IMerchantProfileRepository merchantRepository,
        ISupplierProfileRepository myOwnSupplierRepository)
    {
        _masterOrderRepository = masterOrderRepository;
        _supplierRepository = supplierRepository;
        _merchantRepository = merchantRepository;
        _myOwnSupplierRepository = myOwnSupplierRepository;
    }

    // GET /api/v1/search/orders?q= — scoped to the caller's own orders
    // (their shop's orders if Merchant, orders they fulfill if Supplier);
    // Admin searches everything. Never a cross-account search.
    [HttpGet("orders")]
    public async Task<IActionResult> SearchOrders([FromQuery] string q)
    {
        if (string.IsNullOrWhiteSpace(q)) return Ok(Array.Empty<OrderSearchResultDto>());

        var qLower = q.Trim().ToLower();
        var qAsId = int.TryParse(q.Trim(), out var parsedId) ? parsedId : (int?)null;

        var query = _masterOrderRepository.Query()
            .Include(o => o.Merchant)
            .Include(o => o.SubOrders).ThenInclude(s => s.Supplier)
            .Include(o => o.SubOrders).ThenInclude(s => s.Product)
            .AsQueryable();

        if (User.IsInRole("Merchant"))
        {
            var userId = CurrentUserId();
            if (userId == null) return Unauthorized();
            var shop = (await _merchantRepository.FindAsync(m => m.OwnerUserId == userId)).OrderBy(m => m.CreatedAt).FirstOrDefault();
            if (shop == null) return Ok(Array.Empty<OrderSearchResultDto>());
            query = query.Where(o => o.MerchantId == shop.MerchantID);
        }
        else if (User.IsInRole("Supplier"))
        {
            var userId = CurrentUserId();
            if (userId == null) return Unauthorized();
            var supplier = await _myOwnSupplierRepository.SingleOrDefaultAsync(s => s.OwnerUserId == userId);
            if (supplier == null) return Ok(Array.Empty<OrderSearchResultDto>());
            query = query.Where(o => o.SubOrders.Any(s => s.SupplierId == supplier.SupplierID));
        }
        // Admin: unscoped.

        query = query.Where(o =>
            (qAsId != null && o.Id == qAsId) ||
            o.Merchant.ShopName.ToLower().Contains(qLower) ||
            o.SubOrders.Any(s => (s.Supplier != null && s.Supplier.CompanyName.ToLower().Contains(qLower))
                                  || (s.Product != null && s.Product.Name.ToLower().Contains(qLower))));

        var orders = await query.OrderByDescending(o => o.OrderDate).Take(20).ToListAsync();

        return Ok(orders.Select(o => new OrderSearchResultDto
        {
            Id = o.Id,
            MerchantName = o.Merchant.ShopName,
            Status = o.Status.ToString(),
            TotalAmount = o.TotalAmount,
            OrderDate = o.OrderDate
        }));
    }

    // GET /api/v1/search/suppliers?q= — lightweight typeahead over active
    // suppliers (e.g. picking who to invite to an RFQ). For the full
    // directory experience use GET /api/v1/public/suppliers instead.
    [HttpGet("suppliers")]
    public async Task<IActionResult> SearchSuppliers([FromQuery] string q)
    {
        if (string.IsNullOrWhiteSpace(q)) return Ok(Array.Empty<SupplierSearchResultDto>());

        var qLower = q.Trim().ToLower();

        var suppliers = await _supplierRepository.Query()
            .Where(s => s.IsActiveForRouting && s.CompanyName.ToLower().Contains(qLower))
            .OrderBy(s => s.CompanyName)
            .Take(20)
            .ToListAsync();

        return Ok(suppliers.Select(s => new SupplierSearchResultDto
        {
            SupplierID = s.SupplierID,
            CompanyName = s.CompanyName,
            ReliabilityScore = s.ReliabilityScore
        }));
    }

    private int? CurrentUserId()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(idStr, out var id) ? id : null;
    }
}
