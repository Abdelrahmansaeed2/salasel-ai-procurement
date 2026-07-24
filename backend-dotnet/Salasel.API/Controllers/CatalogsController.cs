using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/suppliers/catalogs")]
[Authorize(Roles = "Supplier,Admin")]
public class CatalogsController : ControllerBase
{
    private readonly ICatalogService _catalogService;

    public CatalogsController(ICatalogService catalogService)
    {
        _catalogService = catalogService;
    }

    [HttpPost("upload")]
    public async Task<IActionResult> UploadCatalog([FromForm] IFormFile pdfCatalog)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        // Future AI integration: RAG Ingestion
        return Accepted(new { Message = "Catalog uploaded successfully", CatalogID = Guid.NewGuid().ToString() });
    }
}