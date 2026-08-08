using Microsoft.EntityFrameworkCore;
using Salasel.Domain.Entities;
using Salasel.Domain.Enums;

namespace Salasel.Infrastructure.Data;

public static class DatabaseSeeder
{
    public static async Task SeedAsync(SalaselDbContext db)
    {
        // Remove the early return so we can seed missing items incrementally
        // if (await db.Users.AnyAsync(u => u.Email == "admin@salasel.com")) { return; }

        var passwordHash = BCrypt.Net.BCrypt.HashPassword("Password123!");

        // 1. Admin
        var admin = await db.Users.FirstOrDefaultAsync(u => u.Email == "admin@salasel.com");
        if (admin == null)
        {
            admin = new User { FullName = "Admin User", Email = "admin@salasel.com", PasswordHash = passwordHash, Role = UserRole.Admin, IsActive = true, IsSetupCompleted = true, CreatedAt = DateTime.UtcNow };
            db.Users.Add(admin);
        }

        // 2. Suppliers
        var supplier1 = await db.Users.FirstOrDefaultAsync(u => u.Email == "supplier1@salasel.com");
        if (supplier1 == null)
        {
            supplier1 = new User { FullName = "First Supplier", Email = "supplier1@salasel.com", PasswordHash = passwordHash, Role = UserRole.Supplier, IsActive = true, IsSetupCompleted = true, CreatedAt = DateTime.UtcNow };
            db.Users.Add(supplier1);
        }

        var supplier2 = await db.Users.FirstOrDefaultAsync(u => u.Email == "supplier2@salasel.com");
        if (supplier2 == null)
        {
            supplier2 = new User { FullName = "Second Supplier", Email = "supplier2@salasel.com", PasswordHash = passwordHash, Role = UserRole.Supplier, IsActive = true, IsSetupCompleted = true, CreatedAt = DateTime.UtcNow };
            db.Users.Add(supplier2);
        }

        // 3. Merchants
        var merchant = await db.Users.FirstOrDefaultAsync(u => u.Email == "merchant@salasel.com");
        if (merchant == null)
        {
            merchant = new User { FullName = "Demo Merchant", Email = "merchant@salasel.com", PasswordHash = passwordHash, Role = UserRole.Merchant, IsActive = true, IsSetupCompleted = true, CreatedAt = DateTime.UtcNow };
            db.Users.Add(merchant);
        }

        await db.SaveChangesAsync(); // Save to get IDs

        // Seed Supplier Profiles
        var sProfile1 = await db.SupplierProfiles.FirstOrDefaultAsync(p => p.OwnerUserId == supplier1.UserID);
        if (sProfile1 == null)
        {
            sProfile1 = new SupplierProfile { OwnerUserId = supplier1.UserID, CompanyName = "Al Marai Distributors", ContactPhone = "+966500000001", VerificationStatus = MerchantVerificationStatus.Approved, IsActiveForRouting = true, CreatedAt = DateTime.UtcNow, RegistrationStep = 4 };
            db.SupplierProfiles.Add(sProfile1);
        }

        var sProfile2 = await db.SupplierProfiles.FirstOrDefaultAsync(p => p.OwnerUserId == supplier2.UserID);
        if (sProfile2 == null)
        {
            sProfile2 = new SupplierProfile { OwnerUserId = supplier2.UserID, CompanyName = "Saudia Wholesale", ContactPhone = "+966500000002", VerificationStatus = MerchantVerificationStatus.Approved, IsActiveForRouting = true, CreatedAt = DateTime.UtcNow, RegistrationStep = 4 };
            db.SupplierProfiles.Add(sProfile2);
        }

        await db.SaveChangesAsync();

        // Seed Merchant Profile
        var mProfile = await db.MerchantsProfiles.FirstOrDefaultAsync(p => p.OwnerUserId == merchant.UserID);
        if (mProfile == null)
        {
            mProfile = new MerchantsProfile
            {
                OwnerUserId = merchant.UserID, ShopName = "Supermarket Riyadh", OwnerName = "Demo Merchant", CrNumber = "1234567890", OwnerIdentityNumber = "1000000000", ContactPhone = "+966500000003", Category = "بقالة", StoreSize = "متوسط", Governorate = "الرياض", BusinessCity = "الرياض", Address = "حي الملقا", IsVerified = false, VerificationStatus = MerchantVerificationStatus.UnderReview, CreatedAt = DateTime.UtcNow
            };
            db.MerchantsProfiles.Add(mProfile);
        }

        await db.SaveChangesAsync();

        // Seed Categories
        var catFood = await db.Categories.FirstOrDefaultAsync(c => c.Name == "Food");
        if (catFood == null) { catFood = new Category { Name = "Food" }; db.Categories.Add(catFood); }

        var catBeverages = await db.Categories.FirstOrDefaultAsync(c => c.Name == "Beverages");
        if (catBeverages == null) { catBeverages = new Category { Name = "Beverages" }; db.Categories.Add(catBeverages); }

        var catDairy = await db.Categories.FirstOrDefaultAsync(c => c.Name == "Dairy");
        if (catDairy == null) { catDairy = new Category { Name = "Dairy" }; db.Categories.Add(catDairy); }
        await db.SaveChangesAsync();

        // Seed Products
        var pSugar = await db.Products.FirstOrDefaultAsync(p => p.SKU == "SUG-1KG");
        if (pSugar == null) { pSugar = new Product { CategoryId = catFood.Id, Name = "Sugar 1kg", SKU = "SUG-1KG", Unit = "kg", IsActive = true }; db.Products.Add(pSugar); }

        var pFlour = await db.Products.FirstOrDefaultAsync(p => p.SKU == "FLR-1KG");
        if (pFlour == null) { pFlour = new Product { CategoryId = catFood.Id, Name = "Flour 1kg", SKU = "FLR-1KG", Unit = "kg", IsActive = true }; db.Products.Add(pFlour); }

        var pCoffee = await db.Products.FirstOrDefaultAsync(p => p.SKU == "COF-500G");
        if (pCoffee == null) { pCoffee = new Product { CategoryId = catBeverages.Id, Name = "Coffee Beans 500g", SKU = "COF-500G", Unit = "bag", IsActive = true }; db.Products.Add(pCoffee); }

        var pMilk = await db.Products.FirstOrDefaultAsync(p => p.SKU == "MLK-1L");
        if (pMilk == null) { pMilk = new Product { CategoryId = catDairy.Id, Name = "Milk 1L", SKU = "MLK-1L", Unit = "bottle", IsActive = true }; db.Products.Add(pMilk); }

        var pRice = await db.Products.FirstOrDefaultAsync(p => p.SKU == "RCE-5KG");
        if (pRice == null) { pRice = new Product { CategoryId = catFood.Id, Name = "Egyptian Rice 5kg", SKU = "RCE-5KG", Unit = "bag", IsActive = true }; db.Products.Add(pRice); }

        var pOil = await db.Products.FirstOrDefaultAsync(p => p.SKU == "OIL-1L");
        if (pOil == null) { pOil = new Product { CategoryId = catFood.Id, Name = "Sunflower Oil 1L", SKU = "OIL-1L", Unit = "bottle", IsActive = true }; db.Products.Add(pOil); }

        await db.SaveChangesAsync();

        // Seed Products for Suppliers
        if (!await db.SupplierProducts.AnyAsync(sp => sp.SupplierId == sProfile1.SupplierID && sp.ProductId == pSugar.Id))
        {
            db.SupplierProducts.AddRange(new List<SupplierProduct>
            {
                new SupplierProduct { SupplierId = sProfile1.SupplierID, ProductId = pSugar.Id, UnitPrice = 5.50m, AvailableQty = 1000, MinOrderQty = 10, LeadTimeDays = 1, IsActive = true },
                new SupplierProduct { SupplierId = sProfile1.SupplierID, ProductId = pFlour.Id, UnitPrice = 3.20m, AvailableQty = 800, MinOrderQty = 10, LeadTimeDays = 1, IsActive = true },
                new SupplierProduct { SupplierId = sProfile1.SupplierID, ProductId = pRice.Id, UnitPrice = 12.50m, AvailableQty = 500, MinOrderQty = 5, LeadTimeDays = 1, IsActive = true },
                new SupplierProduct { SupplierId = sProfile2.SupplierID, ProductId = pCoffee.Id, UnitPrice = 25.00m, AvailableQty = 200, MinOrderQty = 5, LeadTimeDays = 2, IsActive = true },
                new SupplierProduct { SupplierId = sProfile2.SupplierID, ProductId = pMilk.Id, UnitPrice = 4.00m, AvailableQty = 500, MinOrderQty = 20, LeadTimeDays = 1, IsActive = true },
                new SupplierProduct { SupplierId = sProfile2.SupplierID, ProductId = pOil.Id, UnitPrice = 8.00m, AvailableQty = 600, MinOrderQty = 10, LeadTimeDays = 1, IsActive = true },
            });
            await db.SaveChangesAsync();
        }

        // Seed Merchant Inventory
        if (!await db.MerchantInventories.AnyAsync(mi => mi.MerchantID == mProfile.MerchantID))
        {
            db.MerchantInventories.AddRange(new List<MerchantInventory>
            {
                new MerchantInventory { MerchantID = mProfile.MerchantID, ProductId = pSugar.Id, CurrentQty = 50, ReorderThreshold = 10 },
                new MerchantInventory { MerchantID = mProfile.MerchantID, ProductId = pMilk.Id, CurrentQty = 5, ReorderThreshold = 10 },
            });
            await db.SaveChangesAsync();
        }

        // Seed an Order
        if (!await db.MasterOrders.AnyAsync(o => o.MerchantId == mProfile.MerchantID && o.TotalAmount == 145.00m))
        {
            var order = new MasterOrder
            {
                MerchantId = mProfile.MerchantID, TotalAmount = 145.00m, Status = ApprovalStatus.Completed, Source = OrderSource.Voice, OrderDate = DateTime.UtcNow.AddDays(-2), PaymentMethod = PaymentMethod.CashOnDelivery, PaymentStatus = PaymentStatus.Paid,
                SubOrders = new List<SubOrder>
                {
                    new SubOrder { SupplierId = sProfile1.SupplierID, ProductId = pSugar.Id, Quantity = 10, SubTotalAmount = 55.00m, Status = FulfillmentStatus.Delivered, AcceptedAt = DateTime.UtcNow.AddDays(-2).AddHours(1), ShippedAt = DateTime.UtcNow.AddDays(-2).AddHours(5), DeliveredAt = DateTime.UtcNow.AddDays(-1) },
                    new SubOrder { SupplierId = sProfile2.SupplierID, ProductId = pCoffee.Id, Quantity = 2, SubTotalAmount = 50.00m, Status = FulfillmentStatus.Shipped, AcceptedAt = DateTime.UtcNow.AddDays(-2).AddHours(2), ShippedAt = DateTime.UtcNow.AddDays(-1) }
                }
            };
            db.MasterOrders.Add(order);
            await db.SaveChangesAsync();
        }

        // Seed an Active Order for Kanban (Bidding & Preparing)
        if (!await db.MasterOrders.AnyAsync(o => o.MerchantId == mProfile.MerchantID && o.TotalAmount == 320.50m))
        {
            var activeOrder = new MasterOrder
            {
                MerchantId = mProfile.MerchantID, TotalAmount = 320.50m, Status = ApprovalStatus.Pending_Approval, Source = OrderSource.Voice, OrderDate = DateTime.UtcNow, PaymentMethod = PaymentMethod.BankTransfer, PaymentStatus = PaymentStatus.Pending,
                SubOrders = new List<SubOrder>
                {
                    new SubOrder { SupplierId = sProfile1.SupplierID, ProductId = pSugar.Id, Quantity = 20, SubTotalAmount = 110.00m, Status = FulfillmentStatus.Bidding },
                    new SubOrder { SupplierId = sProfile1.SupplierID, ProductId = pFlour.Id, Quantity = 15, SubTotalAmount = 48.00m, Status = FulfillmentStatus.Accepted, AcceptedAt = DateTime.UtcNow.AddMinutes(-30) },
                    new SubOrder { SupplierId = sProfile2.SupplierID, ProductId = pMilk.Id, Quantity = 5, SubTotalAmount = 20.00m, Status = FulfillmentStatus.Shipped, AcceptedAt = DateTime.UtcNow.AddHours(-1), ShippedAt = DateTime.UtcNow.AddMinutes(-10) }
                }
            };
            db.MasterOrders.Add(activeOrder);
            await db.SaveChangesAsync();
        }

        // Seed Supplier Knowledge Documents
        if (!await db.SupplierKnowledgeDocuments.AnyAsync(d => d.SupplierId == sProfile1.SupplierID))
        {
            db.SupplierKnowledgeDocuments.AddRange(new List<SupplierKnowledgeDocument>
            {
                new SupplierKnowledgeDocument { SupplierId = sProfile1.SupplierID, FileName = "Q3_Pricing_Catalog.pdf", FileType = "PDF", FileUrl = "https://example.com/docs/Q3_Pricing.pdf", Status = KnowledgeDocumentStatus.Indexed, ChunkCount = 120, UploadedAt = DateTime.UtcNow.AddDays(-2), IndexedAt = DateTime.UtcNow.AddDays(-2) },
                new SupplierKnowledgeDocument { SupplierId = sProfile1.SupplierID, FileName = "Inventory_Stock_Export.csv", FileType = "CSV", FileUrl = "https://example.com/docs/Inventory_Export.csv", Status = KnowledgeDocumentStatus.Indexed, ChunkCount = 45, UploadedAt = DateTime.UtcNow.AddDays(-1), IndexedAt = DateTime.UtcNow.AddDays(-1) },
                new SupplierKnowledgeDocument { SupplierId = sProfile1.SupplierID, FileName = "Supplier_Agreement_Terms.pdf", FileType = "PDF", FileUrl = "https://example.com/docs/Contract.pdf", Status = KnowledgeDocumentStatus.Failed, ErrorMessage = "PDF text extraction failed due to encryption.", UploadedAt = DateTime.UtcNow, IndexedAt = null }
            });
            await db.SaveChangesAsync();
        }

        // Seed Supplier Warehouses
        if (!await db.SupplierWarehouses.AnyAsync(w => w.SupplierId == sProfile1.SupplierID))
        {
            db.SupplierWarehouses.AddRange(new List<SupplierWarehouse>
            {
                new SupplierWarehouse { SupplierId = sProfile1.SupplierID, WarehouseName = "Main Riyadh Hub", City = "الرياض", Capacity = "High", Lat = 24.7136m, Lng = 46.6753m },
                new SupplierWarehouse { SupplierId = sProfile2.SupplierID, WarehouseName = "Jeddah Distribution Center", City = "جدة", Capacity = "Medium", Lat = 21.4858m, Lng = 39.1925m }
            });
            await db.SaveChangesAsync();
        }

        // Seed Bids for the active bidding order
        var biddingSubOrder = await db.SubOrders.FirstOrDefaultAsync(s => s.Status == FulfillmentStatus.Bidding);
        if (biddingSubOrder != null && !await db.Bids.AnyAsync(b => b.SubOrderId == biddingSubOrder.Id))
        {
            db.Bids.AddRange(new List<Bid>
            {
                new Bid { SubOrderId = biddingSubOrder.Id, SupplierId = sProfile1.SupplierID, Price = 115.50m, Status = BidStatus.Submitted, SubmittedAt = DateTime.UtcNow.AddMinutes(-50) },
                new Bid { SubOrderId = biddingSubOrder.Id, SupplierId = sProfile2.SupplierID, Price = 108.00m, Status = BidStatus.Submitted, SubmittedAt = DateTime.UtcNow.AddMinutes(-10) }
            });
            await db.SaveChangesAsync();
        }

        // Seed Voice Procurement Logs & AI Processing for Analytics
        if (!await db.VoiceProcurementLogs.AnyAsync(v => v.MerchantId == mProfile.MerchantID))
        {
            db.VoiceProcurementLogs.AddRange(new List<VoiceProcurementLog>
            {
                new VoiceProcurementLog 
                { 
                    MerchantId = mProfile.MerchantID, AudioUrl = "https://example.com/audio/req1.wav", Transcript = "أحتاج 10 كيلو سكر", CreatedAt = DateTime.UtcNow.AddDays(-2),
                    AIProcessing = new AIProcessing { ModelUsed = "gemini-2.0-flash", Prompt = "Extract intent", ParsedJson = "{}", Confidence = 0.98m, ProcessingDurationMs = 1250 }
                },
                new VoiceProcurementLog 
                { 
                    MerchantId = mProfile.MerchantID, AudioUrl = "https://example.com/audio/req2.wav", Transcript = "ممكن قهوة و حليب", CreatedAt = DateTime.UtcNow.AddHours(-1),
                    AIProcessing = new AIProcessing { ModelUsed = "gemini-2.0-flash", Prompt = "Extract intent", ParsedJson = "{}", Confidence = 0.95m, ProcessingDurationMs = 1840 }
                }
            });
            await db.SaveChangesAsync();
        }

        // Seed Notifications for Admin/Merchant
        if (!await db.Notifications.AnyAsync(n => n.UserId == admin.UserID))
        {
            db.Notifications.AddRange(new List<Notification>
            {
                new Notification { UserId = admin.UserID, EventName = "NewMerchantRegistered", PayloadJson = "{\"MerchantId\": 1}", IsRead = false, CreatedAt = DateTime.UtcNow.AddHours(-3) },
                new Notification { UserId = merchant.UserID, EventName = "OrderShipped", PayloadJson = "{\"OrderId\": 1}", IsRead = false, CreatedAt = DateTime.UtcNow.AddMinutes(-15) },
                new Notification { UserId = supplier1.UserID, EventName = "NewRFQ", PayloadJson = "{\"RfqId\": 1}", IsRead = true, CreatedAt = DateTime.UtcNow.AddHours(-1) }
            });
            await db.SaveChangesAsync();
        }
    }
}
