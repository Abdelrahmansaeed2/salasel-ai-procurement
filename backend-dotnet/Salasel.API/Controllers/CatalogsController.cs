using Microsoft.AspNetCore.Mvc;
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/suppliers/catalogs")]
public class CatalogsController : ControllerBase
{
    private readonly ICatalogService _catalogService;

    public CatalogsController(ICatalogService catalogService)
    {
        _catalogService = catalogService;
    }

    [HttpPost("upload")]
    public async Task<IActionResult> UploadCatalog([FromBody] CatalogUploadRequestDto request)
    {
        var catalogId = await _catalogService.UploadCatalogAsync(request);
        return Ok(new { Message = "Catalog uploaded successfully", CatalogID = catalogId });
    }
}
