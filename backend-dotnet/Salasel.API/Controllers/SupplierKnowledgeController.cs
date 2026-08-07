using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Salasel.Application.DTOs;
using Salasel.Domain.Entities;
using Salasel.Domain.Enums;
using Salasel.Infrastructure.Data;
using Salasel.Infrastructure.Services;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/suppliers/me/knowledge")]
[Authorize(Roles = "Supplier,Admin")]
public class SupplierKnowledgeController : ControllerBase
{
    private readonly SalaselDbContext _db;
    private readonly IKnowledgeIndexingQueue _queue;
    private readonly IWebHostEnvironment _env;
    private readonly ILogger<SupplierKnowledgeController> _logger;

    private static readonly string[] AllowedExtensions = { ".pdf", ".csv", ".xlsx" };

    public SupplierKnowledgeController(
        SalaselDbContext db,
        IKnowledgeIndexingQueue queue,
        IWebHostEnvironment env,
        ILogger<SupplierKnowledgeController> logger)
    {
        _db = db;
        _queue = queue;
        _env = env;
        _logger = logger;
    }

    [HttpPost("upload")]
    [RequestSizeLimit(20 * 1024 * 1024)]
    public async Task<IActionResult> Upload([FromForm] IFormFile? file)
    {
        var supplier = await GetMySupplierAsync();
        if (supplier == null) return NotFound(new { error = "No supplier profile found for this account." });

        if (file == null || file.Length == 0)
            return BadRequest(new { error = "No file provided." });

        var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (string.IsNullOrEmpty(ext) || !AllowedExtensions.Contains(ext))
            return BadRequest(new { error = "Invalid file type. Only PDF, CSV, and XLSX are allowed." });

        var webRoot = _env.WebRootPath;
        if (string.IsNullOrEmpty(webRoot))
            webRoot = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");

        var uploadsDir = Path.Combine(webRoot, "uploads", "knowledge");
        Directory.CreateDirectory(uploadsDir);

        var storedName = $"{Guid.NewGuid():N}{ext}";
        var fullPath = Path.Combine(uploadsDir, storedName);

        await using (var stream = System.IO.File.Create(fullPath))
        {
            await file.CopyToAsync(stream);
        }

        var doc = new SupplierKnowledgeDocument
        {
            SupplierId = supplier.SupplierID,
            FileName = file.FileName,
            FileUrl = PathHelpers.ToRelative(fullPath, webRoot),
            FileType = ext.TrimStart('.'),
            Status = KnowledgeDocumentStatus.Processing,
            UploadedAt = DateTime.UtcNow
        };

        _db.SupplierKnowledgeDocuments.Add(doc);
        await _db.SaveChangesAsync();

        await _queue.EnqueueAsync(new KnowledgeIndexingJob(doc.Id));

        _logger.LogInformation("Knowledge document {DocumentId} queued for supplier {SupplierId}", doc.Id, supplier.SupplierID);

        return Ok(new { documentId = doc.Id, message = "Document uploaded. Indexing in progress." });
    }

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var supplier = await GetMySupplierAsync();
        if (supplier == null) return NotFound(new { error = "No supplier profile found for this account." });

        var docs = await _db.SupplierKnowledgeDocuments
            .AsNoTracking()
            .Where(d => d.SupplierId == supplier.SupplierID)
            .OrderByDescending(d => d.UploadedAt)
            .Select(d => ToDto(d))
            .ToListAsync();

        return Ok(docs);
    }

    [HttpDelete("{docId:int}")]
    public async Task<IActionResult> Delete(int docId)
    {
        var supplier = await GetMySupplierAsync();
        if (supplier == null) return NotFound(new { error = "No supplier profile found for this account." });

        var doc = await _db.SupplierKnowledgeDocuments
            .FirstOrDefaultAsync(d => d.Id == docId && d.SupplierId == supplier.SupplierID);
        if (doc == null) return NotFound();

        var webRoot = _env.WebRootPath;
        if (string.IsNullOrEmpty(webRoot))
            webRoot = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");

        var fullPath = PathHelpers.ToAbsolute(doc.FileUrl, webRoot);
        if (System.IO.File.Exists(fullPath))
        {
            try { System.IO.File.Delete(fullPath); }
            catch (IOException ex) { _logger.LogWarning(ex, "Could not delete file {Path} on disk.", fullPath); }
        }

        _db.SupplierKnowledgeDocuments.Remove(doc);
        await _db.SaveChangesAsync();

        return NoContent();
    }

    [HttpPost("{docId:int}/reindex")]
    public async Task<IActionResult> Reindex(int docId)
    {
        var supplier = await GetMySupplierAsync();
        if (supplier == null) return NotFound(new { error = "No supplier profile found for this account." });

        var doc = await _db.SupplierKnowledgeDocuments
            .FirstOrDefaultAsync(d => d.Id == docId && d.SupplierId == supplier.SupplierID);
        if (doc == null) return NotFound();

        if (doc.Status == KnowledgeDocumentStatus.Processing)
            return BadRequest(new { error = "This document is already being indexed." });

        doc.Status = KnowledgeDocumentStatus.Processing;
        doc.ErrorMessage = null;
        doc.ChunkCount = null;
        doc.IndexedAt = null;

        await _db.SaveChangesAsync();
        await _queue.EnqueueAsync(new KnowledgeIndexingJob(doc.Id));

        return Ok(new { message = "Re-indexing started.", document = ToDto(doc) });
    }

    private Task<SupplierProfile?> GetMySupplierAsync()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(idStr, out var userId)) return Task.FromResult<SupplierProfile?>(null);

        return _db.SupplierProfiles.FirstOrDefaultAsync(s => s.OwnerUserId == userId)!;
    }

    private static KnowledgeDocumentDto ToDto(SupplierKnowledgeDocument d) => new()
    {
        Id = d.Id,
        FileName = d.FileName,
        FileType = d.FileType,
        FileUrl = d.FileUrl,
        Status = d.Status.ToString(),
        ChunkCount = d.ChunkCount,
        ErrorMessage = d.ErrorMessage,
        UploadedAt = d.UploadedAt,
        IndexedAt = d.IndexedAt
    };
}