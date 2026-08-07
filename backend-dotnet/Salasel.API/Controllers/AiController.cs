using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Domain.Enums;
using Salasel.Domain.Interfaces;
using Salasel.Infrastructure.Services;

namespace Salasel.API.Controllers;

// Rule-based today, not real ML — same honesty as InventoryAlertDto's
// EstimatedDaysUntilStockOut: no fake numbers where there's no data to back
// them (see NextOrderPrediction's HasEnoughData). Swap the internals for a
// real model later without changing these routes.
[ApiController]
[Route("api/v1/ai")]
[Authorize]
public class AiController : ControllerBase
{
    private readonly IInventoryService _inventoryService;
    private readonly ISupplierProductRepository _supplierProductRepository;
    private readonly IRepository<MasterOrder> _orderRepository;
    private readonly IAIService _aiService;

    public AiController(
        IInventoryService inventoryService,
        ISupplierProductRepository supplierProductRepository,
        IRepository<MasterOrder> orderRepository,
        IAIService aiService)
    {
        _inventoryService = inventoryService;
        _supplierProductRepository = supplierProductRepository;
        _orderRepository = orderRepository;
        _aiService = aiService;
    }

    // Inventory AI card — same underlying data as
    // GET /api/v1/inventory/alerts, exposed under the AI namespace too since
    // both paths were requested separately.
    [HttpGet("predictions/out-of-stock")]
    public async Task<IActionResult> GetOutOfStockPredictions([FromQuery] int merchantId)
    {
        var alerts = await _inventoryService.GetAlertsAsync(merchantId);
        return Ok(alerts);
    }

    // Smart suggestions: for each low-stock item, find the best currently
    // listed offer (cheapest active price) to reorder from.
    [HttpGet("recommendations")]
    public async Task<IActionResult> GetRecommendations([FromQuery] int merchantId)
    {
        var alerts = await _inventoryService.GetAlertsAsync(merchantId);
        var recommendations = new List<ProductRecommendationDto>();

        foreach (var alert in alerts)
        {
            var bestOffer = await _supplierProductRepository.Query()
                .Include(sp => sp.Supplier)
                .Where(sp => sp.ProductId == alert.ProductId
                          && sp.IsActive
                          && sp.Supplier.IsActiveForRouting)
                .OrderBy(sp => sp.UnitPrice)
                .FirstOrDefaultAsync();

            recommendations.Add(new ProductRecommendationDto
            {
                ProductId = alert.ProductId,
                ProductName = alert.ProductName,
                Reason = "Stock is at or below the reorder threshold.",
                CurrentQty = alert.CurrentQty,
                ReorderThreshold = alert.ReorderThreshold,
                RecommendedSupplierId = bestOffer?.SupplierId,
                RecommendedSupplierName = bestOffer?.Supplier.CompanyName,
                RecommendedUnitPrice = bestOffer?.UnitPrice,
                RecommendedLeadTimeDays = bestOffer?.LeadTimeDays
            });
        }

        return Ok(recommendations);
    }

    // Optional: naive forecast from the merchant's own order cadence.
    // Needs at least 2 real (non-rejected) past orders — otherwise says so
    // explicitly rather than guessing.
    [HttpGet("next-order")]
    public async Task<IActionResult> GetNextOrderPrediction([FromQuery] int merchantId)
    {
        var orders = (await _orderRepository.FindAsync(
                o => o.MerchantId == merchantId && o.Status != ApprovalStatus.Rejected))
            .OrderBy(o => o.OrderDate)
            .ToList();

        if (orders.Count < 2)
        {
            return Ok(new NextOrderPredictionDto
            {
                MerchantId = merchantId,
                HasEnoughData = false,
                Message = "Not enough order history yet to predict the next order (need at least 2 completed orders)."
            });
        }

        var intervals = orders.Zip(orders.Skip(1), (a, b) => (b.OrderDate - a.OrderDate).TotalDays);
        var avgIntervalDays = intervals.Average();
        var lastOrderDate = orders.Last().OrderDate;

        return Ok(new NextOrderPredictionDto
        {
            MerchantId = merchantId,
            HasEnoughData = true,
            LastOrderDate = lastOrderDate,
            AverageIntervalDays = Math.Round(avgIntervalDays, 1),
            PredictedNextOrderDate = lastOrderDate.AddDays(avgIntervalDays)
        });
    }

    // ───────────────────── Ai-service forwarding proxies ─────────────────────
    // These endpoints are thin relays to the external ai_service (FastAPI) and
    // are intentionally public. They forward the client's request unchanged and
    // return the ai_service response body verbatim (raw JSON), so error details
    // (e.g. 422 on an empty transcript) reach the caller as-is.

    /// <summary>Forward a conversational chat message to the AI service.</summary>
    [HttpPost("chat")]
    [AllowAnonymous]
    public async Task<IActionResult> Chat([FromBody] ChatRequestPayload request)
    {
        AiProxyResponse? result = await _aiService.ChatAsync(request);
        return result.IsSuccess
            ? Content(result.Body, "application/json")
            : StatusCode(result.StatusCode, result.Body);
    }

    /// <summary>Forward a text order for a merchant to the AI service.</summary>
    [HttpPost("order/{merchantId:int}")]
    [AllowAnonymous]
    public async Task<IActionResult> Order(int merchantId, [FromBody] OrderRequestPayload request)
    {
        var result = await _aiService.OrderAsync(merchantId, request);
        return result.IsSuccess
            ? Content(result.Body, "application/json")
            : StatusCode(result.StatusCode, result.Body);
    }

    /// <summary>Forward a voice order (audio upload) for a merchant to the AI service.</summary>
    [HttpPost("voice/order/{merchantId:int}")]
    [AllowAnonymous]
    public async Task<IActionResult> VoiceOrder(
        int merchantId,
        [FromForm] IFormFile? file,
        [FromQuery] double? lat,
        [FromQuery] double? lon)
    {
        if (file is null || file.Length == 0)
            return BadRequest(new { error = "No audio file provided." });

        var result = await _aiService.VoiceOrderAsync(
            merchantId,
            file.OpenReadStream(),
            file.FileName,
            lat ?? 0d,
            lon ?? 0d);

        return result.IsSuccess
            ? Content(result.Body, "application/json")
            : StatusCode(result.StatusCode, result.Body);
    }
}
