using System.Reflection;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Salasel.Application.DTOs;
using Salasel.Domain.Entities;
using Salasel.Domain.Interfaces;
using Salasel.Infrastructure.Data;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/public")]
public class PublicController : ControllerBase
{
    private readonly IRepository<SupplierProfile> _supplierRepository;
    private readonly IRepository<ContactMessage> _contactRepository;
    private readonly IRepository<KnowledgeBaseArticle> _kbRepository;

    public PublicController(
        IRepository<SupplierProfile> supplierRepository,
        IRepository<ContactMessage> contactRepository,
        IRepository<KnowledgeBaseArticle> kbRepository)
    {
        _supplierRepository = supplierRepository;
        _contactRepository = contactRepository;
        _kbRepository = kbRepository;
    }

    [HttpGet("knowledge-base/{category}")]
    public async Task<IActionResult> GetKnowledgeBaseArticles(string category)
    {
        var categoryLower = category.Trim().ToLower();
        var articles = await _kbRepository.Query()
            .Where(a => a.Category.ToLower() == categoryLower)
            .OrderByDescending(a => a.CreatedAt)
            .ToListAsync();

        return Ok(articles.Select(a => new {
            Id = a.Id,
            Title = a.Title,
            Content = a.Content,
            Category = a.Category
        }));
    }

    // GET /api/v1/public/suppliers?q=&city= — directory. Only shows suppliers
    // that have actually passed admin review; a pending/rejected business
    // shouldn't be discoverable from a public marketing page.
    [HttpGet("suppliers")]
    public async Task<IActionResult> GetSuppliers([FromQuery] string? q, [FromQuery] string? city)
    {
        var query = _supplierRepository.Query()
            .Include(s => s.Warehouses)
            .Include(s => s.SupplierProducts)
            .Where(s => s.IsActiveForRouting);

        if (!string.IsNullOrWhiteSpace(q))
        {
            var qLower = q.Trim().ToLower();
            query = query.Where(s => s.CompanyName.ToLower().Contains(qLower));
        }

        if (!string.IsNullOrWhiteSpace(city))
        {
            var cityLower = city.Trim().ToLower();
            query = query.Where(s => s.Warehouses.Any(w => w.City.ToLower() == cityLower));
        }

        var suppliers = await query.ToListAsync();

        return Ok(suppliers.Select(s => new PublicSupplierListItemDto
        {
            SupplierID = s.SupplierID,
            CompanyName = s.CompanyName,
            Cities = s.Warehouses.Select(w => w.City).Distinct().ToList(),
            ReliabilityScore = s.ReliabilityScore,
            ActiveProductCount = s.SupplierProducts.Count(sp => sp.IsActive)
        }));
    }

    // GET /api/v1/public/suppliers/{id} — supplier page
    [HttpGet("suppliers/{id:int}")]
    public async Task<IActionResult> GetSupplier(int id)
    {
        var supplier = await _supplierRepository.Query()
            .Include(s => s.Warehouses)
            .Include(s => s.SupplierProducts)
            .FirstOrDefaultAsync(s => s.SupplierID == id && s.IsActiveForRouting);

        if (supplier == null) return NotFound();

        return Ok(new PublicSupplierDetailDto
        {
            SupplierID = supplier.SupplierID,
            CompanyName = supplier.CompanyName,
            ContactPhone = supplier.ContactPhone,
            Cities = supplier.Warehouses.Select(w => w.City).Distinct().ToList(),
            ReliabilityScore = supplier.ReliabilityScore,
            ActiveProductCount = supplier.SupplierProducts.Count(sp => sp.IsActive),
            MemberSince = supplier.CreatedAt
        });
    }

    // POST /api/v1/public/contact
    [HttpPost("contact")]
    public async Task<IActionResult> SubmitContactForm([FromBody] ContactFormDto request)
    {
        if (string.IsNullOrWhiteSpace(request.Name) || string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Message))
            return BadRequest(new { Message = "Name, email, and message are required." });

        var contact = new ContactMessage
        {
            Name = request.Name.Trim(),
            Email = request.Email.Trim(),
            Phone = request.Phone,
            Subject = request.Subject,
            Message = request.Message.Trim(),
            CreatedAt = DateTime.UtcNow
        };

        await _contactRepository.AddAsync(contact);
        await _contactRepository.SaveChangesAsync();

        // No email/ticketing integration exists yet — this only persists the
        // message. An admin-facing GET/list endpoint can be added once
        // someone actually needs to triage these from the API rather than the DB.
        return Ok(new { Message = "Thanks — we'll get back to you soon." });
    }
}

// GET /api/v1/system/status — richer than /health: real DB connectivity
// check, environment, and app version, not just a 200 OK.
[ApiController]
[Route("api/v1/system")]
public class SystemController : ControllerBase
{
    private readonly SalaselDbContext _db;
    private readonly IHostEnvironment _env;

    public SystemController(SalaselDbContext db, IHostEnvironment env)
    {
        _db = db;
        _env = env;
    }

    [HttpGet("status")]
    public async Task<IActionResult> GetStatus()
    {
        bool dbConnected;
        try
        {
            dbConnected = await _db.Database.CanConnectAsync();
        }
        catch
        {
            dbConnected = false;
        }

        var version = Assembly.GetExecutingAssembly().GetName().Version?.ToString();

        return Ok(new SystemStatusDto
        {
            Status = dbConnected ? "healthy" : "degraded",
            DatabaseConnected = dbConnected,
            Environment = _env.EnvironmentName,
            Version = version,
            ServerTimeUtc = DateTime.UtcNow
        });
    }
}
