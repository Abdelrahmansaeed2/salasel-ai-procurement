using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Salasel.Domain.Entities;
using Salasel.Infrastructure.Data;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/admin/knowledge-base")]
[Authorize(Roles = "Admin")]
public class AdminKnowledgeBaseController : ControllerBase
{
    private readonly SalaselDbContext _context;

    public AdminKnowledgeBaseController(SalaselDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var articles = await _context.KnowledgeBaseArticles
            .OrderByDescending(a => a.CreatedAt)
            .ToListAsync();
        return Ok(articles);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var article = await _context.KnowledgeBaseArticles.FindAsync(id);
        if (article == null) return NotFound();
        return Ok(article);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] KnowledgeBaseArticle article)
    {
        article.CreatedAt = DateTime.UtcNow;
        article.UpdatedAt = DateTime.UtcNow;
        
        await _context.KnowledgeBaseArticles.AddAsync(article);
        await _context.SaveChangesAsync();
        
        return CreatedAtAction(nameof(GetById), new { id = article.Id }, article);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] KnowledgeBaseArticle article)
    {
        if (id != article.Id) return BadRequest("Route ID must match body ID.");

        var existing = await _context.KnowledgeBaseArticles.FindAsync(id);
        if (existing == null) return NotFound();

        existing.Title = article.Title;
        existing.Content = article.Content;
        existing.Category = article.Category;
        existing.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var article = await _context.KnowledgeBaseArticles.FindAsync(id);
        if (article == null) return NotFound();

        _context.KnowledgeBaseArticles.Remove(article);
        await _context.SaveChangesAsync();
        
        return NoContent();
    }
}
