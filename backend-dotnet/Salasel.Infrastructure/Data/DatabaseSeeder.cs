using Microsoft.EntityFrameworkCore;
using Salasel.Domain.Entities;
using Salasel.Domain.Enums;

namespace Salasel.Infrastructure.Data;

public static class DatabaseSeeder
{
    public static async Task SeedAsync(SalaselDbContext db)
    {
        if (await db.Users.AnyAsync(u => u.Email == "admin@salasel.com"))
        {
            return; // DB has already been seeded with the demo admin
        }

        var passwordHash = BCrypt.Net.BCrypt.HashPassword("Password123!");

        // 1. Admin
        var admin = new User
        {
            FullName = "Admin User",
            Email = "admin@salasel.com",
            PasswordHash = passwordHash,
            Role = UserRole.Admin,
            IsActive = true,
            IsSetupCompleted = true,
            CreatedAt = DateTime.UtcNow
        };
        db.Users.Add(admin);

        // 2. Suppliers
        var supplier1 = new User
        {
            FullName = "First Supplier",
            Email = "supplier1@salasel.com",
            PasswordHash = passwordHash,
            Role = UserRole.Supplier,
            IsActive = true,
            IsSetupCompleted = true,
            CreatedAt = DateTime.UtcNow
        };
        db.Users.Add(supplier1);

        var supplier2 = new User
        {
            FullName = "Second Supplier",
            Email = "supplier2@salasel.com",
            PasswordHash = passwordHash,
            Role = UserRole.Supplier,
            IsActive = true,
            IsSetupCompleted = true,
            CreatedAt = DateTime.UtcNow
        };
        db.Users.Add(supplier2);

        // 3. Merchants
        var merchant = new User
        {
            FullName = "Demo Merchant",
            Email = "merchant@salasel.com",
            PasswordHash = passwordHash,
            Role = UserRole.Merchant,
            IsActive = true,
            IsSetupCompleted = true,
            CreatedAt = DateTime.UtcNow
        };
        db.Users.Add(merchant);

        await db.SaveChangesAsync(); // Save to get IDs

        // Seed Supplier Profiles
        var sProfile1 = new SupplierProfile
        {
            OwnerUserId = supplier1.UserID,
            CompanyName = "Al Marai Distributors",
            ContactPhone = "+966500000001",
            VerificationStatus = MerchantVerificationStatus.Approved,
            IsActiveForRouting = true,
            CreatedAt = DateTime.UtcNow,
            RegistrationStep = 4
        };
        db.SupplierProfiles.Add(sProfile1);

        var sProfile2 = new SupplierProfile
        {
            OwnerUserId = supplier2.UserID,
            CompanyName = "Saudia Wholesale",
            ContactPhone = "+966500000002",
            VerificationStatus = MerchantVerificationStatus.Approved,
            IsActiveForRouting = true,
            CreatedAt = DateTime.UtcNow,
            RegistrationStep = 4
        };
        db.SupplierProfiles.Add(sProfile2);

        await db.SaveChangesAsync();

        // Seed Merchant Profile
        var mProfile = new MerchantsProfile
        {
            OwnerUserId = merchant.UserID,
            ShopName = "Supermarket Riyadh",
            OwnerName = "Demo Merchant",
            CrNumber = "1234567890",
            OwnerIdentityNumber = "1000000000",
            ContactPhone = "+966500000003",
            Category = "بقالة",
            StoreSize = "متوسط",
            Governorate = "الرياض",
            BusinessCity = "الرياض",
            Address = "حي الملقا",
            IsVerified = false,
            VerificationStatus = MerchantVerificationStatus.UnderReview, // So it shows in admin pending
            CreatedAt = DateTime.UtcNow
        };
        db.MerchantsProfiles.Add(mProfile);

        await db.SaveChangesAsync();

        // Seed Categories
        var catFood = new Category { Name = "Food" };
        var catBeverages = new Category { Name = "Beverages" };
        var catDairy = new Category { Name = "Dairy" };
        db.Categories.AddRange(catFood, catBeverages, catDairy);
        await db.SaveChangesAsync();

        // Seed Products
        var pSugar = new Product { CategoryId = catFood.Id, Name = "Sugar 1kg", SKU = "SUG-1KG", Unit = "kg", IsActive = true };
        var pFlour = new Product { CategoryId = catFood.Id, Name = "Flour 1kg", SKU = "FLR-1KG", Unit = "kg", IsActive = true };
        var pCoffee = new Product { CategoryId = catBeverages.Id, Name = "Coffee Beans 500g", SKU = "COF-500G", Unit = "bag", IsActive = true };
        var pMilk = new Product { CategoryId = catDairy.Id, Name = "Milk 1L", SKU = "MLK-1L", Unit = "bottle", IsActive = true };
        db.Products.AddRange(pSugar, pFlour, pCoffee, pMilk);
        await db.SaveChangesAsync();

        // Seed Products for Suppliers
        var products = new List<SupplierProduct>
        {
            new SupplierProduct { SupplierId = sProfile1.SupplierID, ProductId = pSugar.Id, UnitPrice = 5.50m, AvailableQty = 1000, MinOrderQty = 10, LeadTimeDays = 1, IsActive = true },
            new SupplierProduct { SupplierId = sProfile1.SupplierID, ProductId = pFlour.Id, UnitPrice = 3.20m, AvailableQty = 800, MinOrderQty = 10, LeadTimeDays = 1, IsActive = true },
            new SupplierProduct { SupplierId = sProfile2.SupplierID, ProductId = pCoffee.Id, UnitPrice = 25.00m, AvailableQty = 200, MinOrderQty = 5, LeadTimeDays = 2, IsActive = true },
            new SupplierProduct { SupplierId = sProfile2.SupplierID, ProductId = pMilk.Id, UnitPrice = 4.00m, AvailableQty = 500, MinOrderQty = 20, LeadTimeDays = 1, IsActive = true },
        };
        db.SupplierProducts.AddRange(products);

        await db.SaveChangesAsync();

        // Seed Merchant Inventory
        var inventories = new List<MerchantInventory>
        {
            new MerchantInventory { MerchantID = mProfile.MerchantID, ProductId = pSugar.Id, CurrentQty = 50, ReorderThreshold = 10 },
            new MerchantInventory { MerchantID = mProfile.MerchantID, ProductId = pMilk.Id, CurrentQty = 5, ReorderThreshold = 10 }, // Low stock!
        };
        db.MerchantInventories.AddRange(inventories);

        // Seed an Order
        var order = new MasterOrder
        {
            MerchantId = mProfile.MerchantID,
            TotalAmount = 145.00m,
            Status = ApprovalStatus.Completed,
            Source = OrderSource.Voice,
            OrderDate = DateTime.UtcNow.AddDays(-2),
            PaymentMethod = PaymentMethod.CashOnDelivery,
            PaymentStatus = PaymentStatus.Paid,
            SubOrders = new List<SubOrder>
            {
                new SubOrder
                {
                    SupplierId = sProfile1.SupplierID,
                    ProductId = pSugar.Id,
                    Quantity = 10,
                    SubTotalAmount = 55.00m,
                    Status = FulfillmentStatus.Delivered,
                    AcceptedAt = DateTime.UtcNow.AddDays(-2).AddHours(1),
                    ShippedAt = DateTime.UtcNow.AddDays(-2).AddHours(5),
                    DeliveredAt = DateTime.UtcNow.AddDays(-1)
                },
                new SubOrder
                {
                    SupplierId = sProfile2.SupplierID,
                    ProductId = pCoffee.Id,
                    Quantity = 2,
                    SubTotalAmount = 50.00m,
                    Status = FulfillmentStatus.Shipped, // Still shipped
                    AcceptedAt = DateTime.UtcNow.AddDays(-2).AddHours(2),
                    ShippedAt = DateTime.UtcNow.AddDays(-1)
                }
            }
        };
        db.MasterOrders.Add(order);

        await db.SaveChangesAsync();
    }
}
