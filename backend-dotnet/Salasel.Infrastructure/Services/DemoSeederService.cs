using Microsoft.EntityFrameworkCore;
using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Domain.Enums;
using Salasel.Infrastructure.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Salasel.Infrastructure.Services;

public class DemoSeederService : IDemoSeederService
{
    private readonly SalaselDbContext _db;

    public DemoSeederService(SalaselDbContext db)
    {
        _db = db;
    }

    public async Task SeedMerchantDemoDataAsync(int userId, int merchantId)
    {
        // 1. Fetch default suppliers and products to link against
        var sProfile1 = await _db.SupplierProfiles.FirstOrDefaultAsync(p => p.CompanyName.Contains("First Supplier") || p.SupplierID == 1);
        var sProfile2 = await _db.SupplierProfiles.FirstOrDefaultAsync(p => p.CompanyName.Contains("Second Supplier") || p.SupplierID == 2);

        var admin = await _db.Users.FirstOrDefaultAsync(u => u.Role == UserRole.Admin);

        var pSugar = await _db.Products.FirstOrDefaultAsync(p => p.Name.Contains("Sugar"));
        var pFlour = await _db.Products.FirstOrDefaultAsync(p => p.Name.Contains("Flour"));
        var pMilk = await _db.Products.FirstOrDefaultAsync(p => p.Name.Contains("Milk"));

        if (sProfile1 == null || sProfile2 == null || pSugar == null || pFlour == null || pMilk == null || admin == null)
        {
            // Initial DB seed has not run yet or data is missing, we can't seed effectively.
            return;
        }

        // 2. Seed MasterOrders & SubOrders
        if (!await _db.MasterOrders.AnyAsync(m => m.MerchantId == merchantId))
        {
            var activeOrder = new MasterOrder
            {
                MerchantId = merchantId,
                TotalAmount = 178.00m,
                Status = ApprovalStatus.Manually_Approved, // Or appropriate status
                OrderDate = DateTime.UtcNow.AddHours(-2),
                SubOrders = new List<SubOrder>
                {
                    new SubOrder { SupplierId = sProfile1.SupplierID, ProductId = pSugar.Id, Quantity = 20, SubTotalAmount = 110.00m, Status = FulfillmentStatus.Bidding },
                    new SubOrder { SupplierId = sProfile1.SupplierID, ProductId = pFlour.Id, Quantity = 15, SubTotalAmount = 48.00m, Status = FulfillmentStatus.Accepted, AcceptedAt = DateTime.UtcNow.AddMinutes(-30) },
                    new SubOrder { SupplierId = sProfile2.SupplierID, ProductId = pMilk.Id, Quantity = 5, SubTotalAmount = 20.00m, Status = FulfillmentStatus.Shipped, AcceptedAt = DateTime.UtcNow.AddHours(-1), ShippedAt = DateTime.UtcNow.AddMinutes(-10) }
                }
            };
            _db.MasterOrders.Add(activeOrder);
            await _db.SaveChangesAsync();

            // Seed Bids for the active bidding order
            var biddingSubOrder = activeOrder.SubOrders.FirstOrDefault(s => s.Status == FulfillmentStatus.Bidding);
            if (biddingSubOrder != null)
            {
                _db.Bids.AddRange(new List<Bid>
                {
                    new Bid { SubOrderId = biddingSubOrder.Id, SupplierId = sProfile1.SupplierID, Price = 115.50m, Status = BidStatus.Submitted, SubmittedAt = DateTime.UtcNow.AddMinutes(-50) },
                    new Bid { SubOrderId = biddingSubOrder.Id, SupplierId = sProfile2.SupplierID, Price = 108.00m, Status = BidStatus.Submitted, SubmittedAt = DateTime.UtcNow.AddMinutes(-10) }
                });
                await _db.SaveChangesAsync();
            }
        }

        // 3. Seed Voice Procurement Logs & AI Processing for Analytics
        if (!await _db.VoiceProcurementLogs.AnyAsync(v => v.MerchantId == merchantId))
        {
            _db.VoiceProcurementLogs.AddRange(new List<VoiceProcurementLog>
            {
                new VoiceProcurementLog 
                { 
                    MerchantId = merchantId, AudioUrl = "https://example.com/audio/req1.wav", Transcript = "أحتاج 10 كيلو سكر", CreatedAt = DateTime.UtcNow.AddDays(-2),
                    AIProcessing = new AIProcessing { ModelUsed = "gemini-2.0-flash", Prompt = "Extract intent", ParsedJson = "{}", Confidence = 0.98m, ProcessingDurationMs = 1250 }
                },
                new VoiceProcurementLog 
                { 
                    MerchantId = merchantId, AudioUrl = "https://example.com/audio/req2.wav", Transcript = "ممكن قهوة و حليب", CreatedAt = DateTime.UtcNow.AddHours(-1),
                    AIProcessing = new AIProcessing { ModelUsed = "gemini-2.0-flash", Prompt = "Extract intent", ParsedJson = "{}", Confidence = 0.95m, ProcessingDurationMs = 1840 }
                }
            });
            await _db.SaveChangesAsync();
        }

        // 4. Seed Notifications for this Merchant
        if (!await _db.Notifications.AnyAsync(n => n.UserId == userId))
        {
            _db.Notifications.AddRange(new List<Notification>
            {
                new Notification { UserId = userId, EventName = "Welcome", PayloadJson = $"{{\"MerchantId\": {merchantId}}}", IsRead = false, CreatedAt = DateTime.UtcNow.AddHours(-3) },
                new Notification { UserId = userId, EventName = "OrderShipped", PayloadJson = $"{{\"OrderId\": 1}}", IsRead = false, CreatedAt = DateTime.UtcNow.AddMinutes(-15) },
            });
            await _db.SaveChangesAsync();
        }
    }
}
