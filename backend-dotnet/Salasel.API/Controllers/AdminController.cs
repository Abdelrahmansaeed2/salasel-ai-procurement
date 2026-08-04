using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Domain.Enums;
using Salasel.Infrastructure.Data;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/admin")]
[Authorize(Roles = "Admin")]
public class AdminController : ControllerBase
{
    private readonly SalaselDbContext _context;

    public AdminController(SalaselDbContext context)
    {
        _context = context;
    }

    [HttpGet("merchants/pending")]
    public async Task<IActionResult> GetPendingMerchants()
    {
        var pendingMerchants = await _context.MerchantsProfiles
            .Where(m => m.VerificationStatus == MerchantVerificationStatus.UnderReview)
            .OrderByDescending(m => m.CreatedAt)
            .Select(m => new
            {
                m.MerchantID,
                m.ShopName,
                m.OwnerName,
                m.CrNumber,
                m.BusinessCity,
                m.CreatedAt,
                VerificationStatus = m.VerificationStatus.ToString()
            })
            .ToListAsync();

        return Ok(pendingMerchants);
    }

    [HttpPut("merchants/{id:int}/approve")]
    public async Task<IActionResult> ApproveMerchant(int id)
    {
        var merchant = await _context.MerchantsProfiles.FindAsync(id);
        if (merchant == null)
            return NotFound(new { Message = "Merchant not found." });

        if (merchant.VerificationStatus == MerchantVerificationStatus.Approved)
            return BadRequest(new { Message = "Merchant is already approved." });

        merchant.VerificationStatus = MerchantVerificationStatus.Approved;
        merchant.IsVerified = true;

        await _context.SaveChangesAsync();
        return Ok(new { Message = "Merchant approved successfully." });
    }

    [HttpGet("analytics")]
    public async Task<IActionResult> GetAnalytics()
    {
        var totalMerchants = await _context.MerchantsProfiles.CountAsync();
        var totalSuppliers = await _context.SupplierProfiles.CountAsync();
        var totalOrders = await _context.MasterOrders.CountAsync();
        var totalGmv = await _context.MasterOrders
            .Where(o => o.Status == ApprovalStatus.Completed || o.Status == ApprovalStatus.Manually_Approved)
            .SumAsync(o => o.TotalAmount);
            
        var totalSubOrders = await _context.SubOrders.CountAsync();

        return Ok(new
        {
            TotalMerchants = totalMerchants,
            TotalSuppliers = totalSuppliers,
            TotalOrders = totalOrders,
            TotalGmv = totalGmv,
            TotalRfqs = totalSubOrders
        });
    }
}
