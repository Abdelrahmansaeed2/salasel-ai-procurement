using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Salasel.Application.DTOs;
using Salasel.Domain.Entities;
using Salasel.Domain.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/products")]
[Authorize] // any authenticated role can search the shared catalog
public class ProductsController : ControllerBase
{
    private readonly IRepository<Product> _productRepository;

    public ProductsController(IRepository<Product> productRepository)
    {
        _productRepository = productRepository;
    }

    // GET /api/v1/products/search?q= — e.g. adding a product to a draft order
    [HttpGet("search")]
    public async Task<IActionResult> Search([FromQuery] string q)
    {
        if (string.IsNullOrWhiteSpace(q) || q.Trim().Length < 2)
            return Ok(Array.Empty<ProductSearchResultDto>()); // avoid a full-table scan on a near-empty query

        var qLower = q.Trim().ToLower();

        var products = await _productRepository.Query()
            .Include(p => p.Category)
            .Where(p => p.IsActive && (p.Name.ToLower().Contains(qLower) || p.SKU.ToLower().Contains(qLower)))
            .OrderBy(p => p.Name)
            .Take(20)
            .ToListAsync();

        return Ok(products.Select(p => new ProductSearchResultDto
        {
            Id = p.Id,
            Name = p.Name,
            SKU = p.SKU,
            Unit = p.Unit,
            CategoryId = p.CategoryId,
            CategoryName = p.Category?.Name ?? string.Empty,
            ImageUrl = p.ImageUrl
        }));
    }
}
