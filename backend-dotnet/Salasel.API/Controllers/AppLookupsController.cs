using Microsoft.AspNetCore.Mvc;
using Salasel.Application.DTOs;

namespace Salasel.API.Controllers;

// Static lists rather than DB tables — there's no admin-editable "cities" or
// "shop categories" concept in the schema (MerchantsProfile.BusinessCity and
// .Category are free-text). If these ever need to be admin-managed, move
// them into real lookup tables; until then a static list is honest about
// what actually backs them.
[ApiController]
[Route("api/v1/lookups")]
public class AppLookupsController : ControllerBase
{
    private static readonly string[] Cities =
    {
        "Cairo", "Giza", "Alexandria", "Sharm El Sheikh", "Hurghada",
        "Mansoura", "Tanta", "Zagazig", "Ismailia", "Port Said",
        "Suez", "Aswan", "Luxor", "Minya", "Sohag", "Assiut"
    };

    private static readonly string[] ShopCategories =
    {
        "Grocery", "Supermarket", "Convenience Store", "Pharmacy", "Restaurant",
        "Cafe", "Bakery", "Butcher", "Other"
    };

    // GET /api/v1/lookups/cities
    [HttpGet("cities")]
    public IActionResult GetCities() =>
        Ok(Cities.Select(c => new LookupItemDto { Value = c, Label = c }));

    // GET /api/v1/lookups/shop-categories
    [HttpGet("shop-categories")]
    public IActionResult GetShopCategories() =>
        Ok(ShopCategories.Select(c => new LookupItemDto { Value = c, Label = c }));
}
