using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
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

    // ─────────────────────────── Merchant moderation ───────────────────────

    [HttpGet("pending-merchants")]
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

    [HttpPut("merchants/{id:int}/reject")]
    public async Task<IActionResult> RejectMerchant(int id, [FromBody] AdminRejectRequest? request)
    {
        var merchant = await _context.MerchantsProfiles.FindAsync(id);
        if (merchant == null)
            return NotFound(new { Message = "Merchant not found." });

        merchant.VerificationStatus = MerchantVerificationStatus.Rejected;
        merchant.IsVerified = false;

        await _context.SaveChangesAsync();
        return Ok(new { Message = "Merchant rejected.", Reason = request?.Reason });
    }

    // ─────────────────────────── Supplier moderation ───────────────────────

    [HttpGet("pending-suppliers")]
    public async Task<IActionResult> GetPendingSuppliers()
    {
        var pendingSuppliers = await _context.SupplierProfiles
            .Where(s => s.VerificationStatus == MerchantVerificationStatus.UnderReview)
            .OrderByDescending(s => s.CreatedAt)
            .Select(s => new
            {
                s.SupplierID,
                s.CompanyName,
                s.CrNumber,
                s.RegistrationStep,
                s.CreatedAt,
                VerificationStatus = s.VerificationStatus.ToString()
            })
            .ToListAsync();

        return Ok(pendingSuppliers);
    }

    [HttpPut("suppliers/{id:int}/approve")]
    public async Task<IActionResult> ApproveSupplier(int id)
    {
        var supplier = await _context.SupplierProfiles.FindAsync(id);
        if (supplier == null)
            return NotFound(new { Message = "Supplier not found." });

        if (supplier.VerificationStatus == MerchantVerificationStatus.Approved)
            return BadRequest(new { Message = "Supplier is already approved." });

        supplier.VerificationStatus = MerchantVerificationStatus.Approved;
        supplier.IsActiveForRouting = true;

        await _context.SaveChangesAsync();
        return Ok(new { Message = "Supplier approved successfully." });
    }

    [HttpPut("suppliers/{id:int}/reject")]
    public async Task<IActionResult> RejectSupplier(int id, [FromBody] AdminRejectRequest? request)
    {
        var supplier = await _context.SupplierProfiles.FindAsync(id);
        if (supplier == null)
            return NotFound(new { Message = "Supplier not found." });

        supplier.VerificationStatus = MerchantVerificationStatus.Rejected;
        supplier.IsActiveForRouting = false;

        await _context.SaveChangesAsync();
        return Ok(new { Message = "Supplier rejected.", Reason = request?.Reason });
    }

    // ────────────────────────────── Analytics ───────────────────────────────

    [HttpGet("analytics")]
    public async Task<IActionResult> GetAnalytics()
    {
        var activeMerchants = await _context.MerchantsProfiles
            .CountAsync(m => m.VerificationStatus == MerchantVerificationStatus.Approved);

        var activeSuppliers = await _context.SupplierProfiles
            .CountAsync(s => s.VerificationStatus == MerchantVerificationStatus.Approved);

        var totalGmv = await _context.MasterOrders
            .Where(o => o.Status == ApprovalStatus.Completed || o.Status == ApprovalStatus.Manually_Approved)
            .SumAsync(o => (decimal?)o.TotalAmount) ?? 0m;

        // Average of every recorded AI voice-processing duration (see
        // AIProcessing.ProcessingDurationMs, measured in VoiceProcessingWorker).
        var avgLatencyMs = await _context.AIProcessings
            .Where(a => a.ProcessingDurationMs != null)
            .AverageAsync(a => (double?)a.ProcessingDurationMs);

        return Ok(new
        {
            totalGmv,
            activeMerchants,
            activeSuppliers,
            averageAiLatency = avgLatencyMs.HasValue ? $"{Math.Round(avgLatencyMs.Value)}ms" : "N/A"
        });
    }
}

public class AdminRejectRequest
{
    public string? Reason { get; set; }
}