using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/inventory")]
[Authorize(Roles = "Merchant,Admin")]
public class InventoryController : ControllerBase
{
    private readonly IInventoryService _inventoryService;
    private readonly IMerchantProfileRepository _merchantRepository;
    private readonly IRepository<Product> _productRepository;

    public InventoryController(
        IInventoryService inventoryService, 
        IMerchantProfileRepository merchantRepository,
        IRepository<Product> productRepository)
    {
        _inventoryService = inventoryService;
        _merchantRepository = merchantRepository;
        _productRepository = productRepository;
    }

    // Kept for backward compatibility with any client already calling this;
    // GET /api/v1/inventory (below) is the fuller replacement with filters.
    [HttpGet("status")]
    public async Task<IActionResult> GetInventoryStatus([FromQuery] int merchantId)
    {
        if (merchantId <= 0) return BadRequest(new { Message = "A valid merchantId is required." });
        if (!await CanAccessMerchantAsync(merchantId)) return Forbid();

        var inventory = await _inventoryService.GetInventoryListAsync(merchantId, category: null, q: null, status: null);
        return Ok(inventory);
    }

    // GET /api/v1/inventory?merchantId=&category=&q=&status=
    [HttpGet]
    public async Task<IActionResult> GetInventory(
        [FromQuery] int merchantId,
        [FromQuery] string? category,
        [FromQuery] string? q,
        [FromQuery] string? status)
    {
        if (merchantId <= 0) return BadRequest(new { Message = "A valid merchantId is required." });
        if (!await CanAccessMerchantAsync(merchantId)) return Forbid();

        var result = await _inventoryService.GetInventoryListAsync(merchantId, category, q, status);
        return Ok(result);
    }

    // POST /api/v1/inventory
    [HttpPost]
    public async Task<IActionResult> AddItem([FromBody] AddInventoryItemDto request)
    {
        if (request.MerchantID <= 0) return BadRequest(new { Message = "MerchantID is required." });
        if (!await CanAccessMerchantAsync(request.MerchantID)) return Forbid();

        if (request.ProductId == null && string.IsNullOrWhiteSpace(request.CustomProductName))
            return BadRequest(new { Message = "Either ProductId or CustomProductName is required." });

        var created = await _inventoryService.AddItemAsync(request);
        return CreatedAtAction(nameof(GetById), new { id = created.InventoryID }, created);
    }

    // GET /api/v1/inventory/{id}
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var item = await _inventoryService.GetInventoryItemAsync(id);
        if (item == null) return NotFound();
        if (!await CanAccessMerchantAsync(item.MerchantID)) return Forbid();

        return Ok(item);
    }

    // GET /api/v1/inventory/lookup?barcode=...
    [HttpGet("lookup")]
    public async Task<IActionResult> LookupByBarcode([FromQuery] string barcode)
    {
        if (string.IsNullOrWhiteSpace(barcode)) return BadRequest("Barcode is required.");
        
        var product = await _productRepository.Query()
            .Include(p => p.Category)
            .FirstOrDefaultAsync(p => p.SKU == barcode);
            
        if (product == null) return NotFound(new { Message = "Product not found." });
        
        return Ok(new
        {
            ProductId = product.Id,
            ProductName = product.Name,
            CategoryName = product.Category?.Name,
            Unit = product.Unit,
            ImageUrl = product.ImageUrl
        });
    }

    // PUT /api/v1/inventory/{id} — edit quantity / fields
    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateInventoryItemDto request)
    {
        var existing = await _inventoryService.GetInventoryItemAsync(id);
        if (existing == null) return NotFound();
        if (!await CanAccessMerchantAsync(existing.MerchantID)) return Forbid();

        var updated = await _inventoryService.UpdateInventoryItemAsync(id, request);
        return Ok(updated);
    }

    // PUT /api/v1/inventory/{id}/quantity — quick qty update
    [HttpPut("{id:int}/quantity")]
    public async Task<IActionResult> UpdateQuantity(int id, [FromBody] UpdateInventoryQuantityDto request)
    {
        var existing = await _inventoryService.GetInventoryItemAsync(id);
        if (existing == null) return NotFound();
        if (!await CanAccessMerchantAsync(existing.MerchantID)) return Forbid();

        var updated = await _inventoryService.UpdateQuantityAsync(id, request);
        return Ok(updated);
    }

    // POST /api/v1/inventory/{id}/reorder — one-tap reorder
    [HttpPost("{id:int}/reorder")]
    public async Task<IActionResult> Reorder(int id, [FromBody] ReorderRequestDto? request)
    {
        var existing = await _inventoryService.GetInventoryItemAsync(id);
        if (existing == null) return NotFound();
        if (!await CanAccessMerchantAsync(existing.MerchantID)) return Forbid();

        try
        {
            var result = await _inventoryService.ReorderAsync(id, request ?? new ReorderRequestDto());
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }

    // GET /api/v1/inventory/alerts?merchantId=
    [HttpGet("alerts")]
    public async Task<IActionResult> GetAlerts([FromQuery] int merchantId)
    {
        if (merchantId <= 0) return BadRequest(new { Message = "A valid merchantId is required." });
        if (!await CanAccessMerchantAsync(merchantId)) return Forbid();

        var alerts = await _inventoryService.GetAlertsAsync(merchantId);
        return Ok(alerts);
    }

    // POST /api/v1/inventory/alerts/{id}/dismiss — ignore alert
    [HttpPost("alerts/{id:int}/dismiss")]
    public async Task<IActionResult> DismissAlert(int id)
    {
        var existing = await _inventoryService.GetInventoryItemAsync(id);
        if (existing == null) return NotFound();
        if (!await CanAccessMerchantAsync(existing.MerchantID)) return Forbid();

        await _inventoryService.DismissAlertAsync(id);
        return Ok(new { Message = "Alert dismissed." });
    }

    // POST /api/v1/inventory/alerts/{id}/add-to-order — add suggestion to order
    [HttpPost("alerts/{id:int}/add-to-order")]
    public async Task<IActionResult> AddAlertToOrder(int id)
    {
        var existing = await _inventoryService.GetInventoryItemAsync(id);
        if (existing == null) return NotFound();
        if (!await CanAccessMerchantAsync(existing.MerchantID)) return Forbid();

        try
        {
            var result = await _inventoryService.AddAlertToOrderAsync(id);
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }

    // ───────────────────────────── Helpers ─────────────────────────────────

    // Admins can access any merchant's inventory; a Merchant user can only
    // access shops they own.
    private async Task<bool> CanAccessMerchantAsync(int merchantId)
    {
        if (User.IsInRole("Admin")) return true;

        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var userId)) return false;

        var shop = await _merchantRepository.SingleOrDefaultAsync(m => m.MerchantID == merchantId && m.OwnerUserId == userId);
        return shop != null;
    }
}
