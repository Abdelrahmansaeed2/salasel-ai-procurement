using Microsoft.EntityFrameworkCore;
using Salasel.Domain.Entities;

namespace Salasel.Infrastructure.Data;

public class SalaselDbContext : DbContext
{
    public SalaselDbContext(DbContextOptions<SalaselDbContext> options) : base(options) { }

    public DbSet<User> Users { get; set; } = null!;
    public DbSet<MerchantsProfile> MerchantsProfiles { get; set; } = null!;
    public DbSet<SupplierProfile> SupplierProfiles { get; set; } = null!;
    public DbSet<Category> Categories { get; set; } = null!;
    public DbSet<Product> Products { get; set; } = null!;
    public DbSet<MerchantInventory> MerchantInventories { get; set; } = null!;
    public DbSet<SupplierProduct> SupplierProducts { get; set; } = null!;
    public DbSet<MasterOrder> MasterOrders { get; set; } = null!;
    public DbSet<SubOrder> SubOrders { get; set; } = null!;
    public DbSet<VoiceProcurementLog> VoiceProcurementLogs { get; set; } = null!;
    public DbSet<AIProcessing> AIProcessings { get; set; } = null!;
    public DbSet<MerchantDocument> MerchantDocuments { get; set; } = null!;
    public DbSet<Bid> Bids { get; set; } = null!;
    public DbSet<SupplierWarehouse> SupplierWarehouses { get; set; } = null!;
    public DbSet<SupplierKnowledgeDocument> SupplierKnowledgeDocuments { get; set; } = null!;
    public DbSet<KnowledgeBaseArticle> KnowledgeBaseArticles { get; set; } = null!;
    public DbSet<Notification> Notifications { get; set; } = null!;
    public DbSet<ContactMessage> ContactMessages { get; set; } = null!;
    public DbSet<UserNotificationSettings> UserNotificationSettings { get; set; } = null!;

    public DbSet<ReturnRequest> ReturnRequests { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // ─── Keys ───────────────────────────────────────────────────────────────
        modelBuilder.Entity<User>().HasKey(u => u.UserID);
        modelBuilder.Entity<MerchantsProfile>().HasKey(m => m.MerchantID);
        modelBuilder.Entity<SupplierProfile>().HasKey(s => s.SupplierID);
        modelBuilder.Entity<MerchantInventory>().HasKey(m => m.InventoryID);
        modelBuilder.Entity<MerchantDocument>().HasKey(d => d.Id);
        modelBuilder.Entity<SupplierKnowledgeDocument>().HasKey(d => d.Id);
        modelBuilder.Entity<KnowledgeBaseArticle>().HasKey(k => k.Id);

        // ─── Unique Indexes ──────────────────────────────────────────────────────
        modelBuilder.Entity<User>().HasIndex(u => u.Email).IsUnique();
        modelBuilder.Entity<Product>().HasIndex(p => p.SKU).IsUnique();

        // ─── Enum → String Conversions ───────────────────────────────────────────
        modelBuilder.Entity<User>().Property(u => u.Role).HasConversion<string>().HasMaxLength(20);
        modelBuilder.Entity<MasterOrder>().Property(m => m.Status).HasConversion<string>().HasMaxLength(30);
        modelBuilder.Entity<MasterOrder>().Property(m => m.Source).HasConversion<string>().HasMaxLength(20);
        modelBuilder.Entity<ReturnRequest>().Property(r => r.Status).HasConversion<string>().HasMaxLength(30);
        modelBuilder.Entity<MasterOrder>().Property(m => m.PaymentMethod).HasConversion<string>().HasMaxLength(20);
        modelBuilder.Entity<MasterOrder>().Property(m => m.PaymentStatus).HasConversion<string>().HasMaxLength(20);
        modelBuilder.Entity<SubOrder>().Property(s => s.Status).HasConversion<string>().HasMaxLength(30);
        modelBuilder.Entity<MerchantsProfile>().Property(m => m.VerificationStatus).HasConversion<string>().HasMaxLength(20);
        modelBuilder.Entity<MerchantDocument>().Property(d => d.DocumentType).HasConversion<string>().HasMaxLength(30);

        // ─── MaxLength on Strings ────────────────────────────────────────────────
        modelBuilder.Entity<User>().Property(u => u.FullName).HasMaxLength(150);
        modelBuilder.Entity<User>().Property(u => u.Email).HasMaxLength(200);

        modelBuilder.Entity<MerchantsProfile>().Property(m => m.ShopName).HasMaxLength(200);
        modelBuilder.Entity<MerchantsProfile>().Property(m => m.ContactPhone).HasMaxLength(30);
        modelBuilder.Entity<MerchantsProfile>().Property(m => m.OwnerName).HasMaxLength(150);
        modelBuilder.Entity<MerchantsProfile>().Property(m => m.CrNumber).HasMaxLength(50);
        modelBuilder.Entity<MerchantsProfile>().Property(m => m.OwnerIdentityNumber).HasMaxLength(50);
        modelBuilder.Entity<MerchantsProfile>().Property(m => m.Category).HasMaxLength(100);
        modelBuilder.Entity<MerchantsProfile>().Property(m => m.StoreSize).HasMaxLength(50);
        modelBuilder.Entity<MerchantsProfile>().Property(m => m.Governorate).HasMaxLength(100);
        modelBuilder.Entity<MerchantsProfile>().Property(m => m.BusinessCity).HasMaxLength(100);
        modelBuilder.Entity<MerchantsProfile>().Property(m => m.Address).HasMaxLength(300);

        modelBuilder.Entity<MerchantDocument>().Property(d => d.FileUrl).IsRequired().HasMaxLength(500);

        modelBuilder.Entity<SupplierProfile>().Property(s => s.CompanyName).HasMaxLength(200);
        modelBuilder.Entity<SupplierProfile>().Property(s => s.ContactPhone).HasMaxLength(30);
        modelBuilder.Entity<SupplierProfile>().Property(s => s.PaymentTerms).HasMaxLength(100);
        modelBuilder.Entity<SupplierProfile>().Property(s => s.CrNumber).HasMaxLength(20);
        modelBuilder.Entity<SupplierProfile>().Property(s => s.TaxNumber).HasMaxLength(20);
        modelBuilder.Entity<SupplierProfile>().Property(s => s.BankName).HasMaxLength(150);
        modelBuilder.Entity<SupplierProfile>().Property(s => s.Iban).HasMaxLength(34);
        modelBuilder.Entity<SupplierProfile>().Property(s => s.VerificationStatus).HasConversion<string>().HasMaxLength(20);

        modelBuilder.Entity<SupplierWarehouse>().Property(w => w.City).HasMaxLength(100);

        modelBuilder.Entity<Category>().Property(c => c.Name).HasMaxLength(100);
        modelBuilder.Entity<KnowledgeBaseArticle>().Property(k => k.Title).HasMaxLength(250);
        modelBuilder.Entity<KnowledgeBaseArticle>().Property(k => k.Category).HasMaxLength(100);

        modelBuilder.Entity<Product>().Property(p => p.Name).HasMaxLength(200);
        modelBuilder.Entity<Product>().Property(p => p.SKU).HasMaxLength(100);
        modelBuilder.Entity<Product>().Property(p => p.Unit).HasMaxLength(30);

        modelBuilder.Entity<AIProcessing>().Property(a => a.ModelUsed).HasMaxLength(60);

        modelBuilder.Entity<MasterOrder>().Property(m => m.PaymentReference).HasMaxLength(100);
        modelBuilder.Entity<SubOrder>().Property(s => s.DriverName).HasMaxLength(150);
        modelBuilder.Entity<SubOrder>().Property(s => s.DriverPhone).HasMaxLength(30);

        // ─── Decimal Precision ───────────────────────────────────────────────────
        modelBuilder.Entity<MasterOrder>().Property(o => o.TotalAmount).HasPrecision(18, 4);

        modelBuilder.Entity<SubOrder>().Property(s => s.SubTotalAmount).HasPrecision(18, 4);

        modelBuilder.Entity<SupplierProduct>().Property(p => p.UnitPrice).HasPrecision(18, 4);

        modelBuilder.Entity<SupplierProfile>().Property(s => s.ReliabilityScore).HasPrecision(5, 2);
        modelBuilder.Entity<SupplierProfile>().Property(s => s.LocationLat).HasPrecision(10, 6);
        modelBuilder.Entity<SupplierProfile>().Property(s => s.LocationLng).HasPrecision(10, 6);
        modelBuilder.Entity<SupplierProfile>().Property(s => s.CoverageRadiusKm).HasPrecision(8, 2);

        modelBuilder.Entity<SupplierWarehouse>().Property(w => w.Lat).HasPrecision(10, 6);
        modelBuilder.Entity<SupplierWarehouse>().Property(w => w.Lng).HasPrecision(10, 6);

        modelBuilder.Entity<MerchantsProfile>().Property(m => m.LocationLat).HasPrecision(10, 6);
        modelBuilder.Entity<MerchantsProfile>().Property(m => m.LocationLng).HasPrecision(10, 6);

        modelBuilder.Entity<AIProcessing>().Property(a => a.Confidence).HasPrecision(5, 4);

        // ─── Relationships ────────────────────────────────────────────────────────

        // User → MerchantsProfile (1-to-many)
        modelBuilder.Entity<MerchantsProfile>()
            .HasOne(m => m.Owner)
            .WithMany(u => u.MerchantsProfiles)
            .HasForeignKey(m => m.OwnerUserId)
            .OnDelete(DeleteBehavior.Restrict);

        // User → SupplierProfile (1-to-many)
        modelBuilder.Entity<SupplierProfile>()
            .HasOne(s => s.Owner)
            .WithMany(u => u.SupplierProfiles)
            .HasForeignKey(s => s.OwnerUserId)
            .OnDelete(DeleteBehavior.Restrict);

        // Category → Product
        modelBuilder.Entity<Product>()
            .HasOne(p => p.Category)
            .WithMany(c => c.Products)
            .HasForeignKey(p => p.CategoryId)
            .OnDelete(DeleteBehavior.Restrict);

        // MerchantsProfile → MerchantInventory
        modelBuilder.Entity<MerchantInventory>()
            .HasOne(i => i.Merchant)
            .WithMany(m => m.Inventories)
            .HasForeignKey(i => i.MerchantID)
            .OnDelete(DeleteBehavior.Cascade);

        // MerchantsProfile → MerchantDocument
        modelBuilder.Entity<MerchantDocument>()
            .HasOne(d => d.Merchant)
            .WithMany(m => m.Documents)
            .HasForeignKey(d => d.MerchantId)
            .OnDelete(DeleteBehavior.Cascade);

        // Product → MerchantInventory
        modelBuilder.Entity<MerchantInventory>()
            .HasOne(i => i.Product)
            .WithMany(p => p.MerchantInventories)
            .HasForeignKey(i => i.ProductId)
            .OnDelete(DeleteBehavior.Restrict);

        // SupplierProfile → SupplierProduct
        modelBuilder.Entity<SupplierProduct>()
            .HasOne(sp => sp.Supplier)
            .WithMany(s => s.SupplierProducts)
            .HasForeignKey(sp => sp.SupplierId)
            .OnDelete(DeleteBehavior.Cascade);

        // SupplierProfile → SupplierWarehouse
        modelBuilder.Entity<SupplierWarehouse>()
            .HasOne(w => w.Supplier)
            .WithMany(s => s.Warehouses)
            .HasForeignKey(w => w.SupplierId)
            .OnDelete(DeleteBehavior.Cascade);

        // SupplierProfile → SupplierKnowledgeDocument
        modelBuilder.Entity<SupplierKnowledgeDocument>()
            .HasOne(d => d.Supplier)
            .WithMany()
            .HasForeignKey(d => d.SupplierId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<SupplierKnowledgeDocument>().Property(d => d.FileName).HasMaxLength(255);
        modelBuilder.Entity<SupplierKnowledgeDocument>().Property(d => d.FileUrl).HasMaxLength(500);
        modelBuilder.Entity<SupplierKnowledgeDocument>().Property(d => d.FileType).HasMaxLength(10);
        modelBuilder.Entity<SupplierKnowledgeDocument>().Property(d => d.Status).HasConversion<string>().HasMaxLength(20);

        // User → Notification
        modelBuilder.Entity<Notification>()
            .HasOne(n => n.User)
            .WithMany()
            .HasForeignKey(n => n.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Notification>().Property(n => n.EventName).HasMaxLength(60);
        modelBuilder.Entity<Notification>().HasIndex(n => new { n.UserId, n.IsRead });

        modelBuilder.Entity<ContactMessage>().Property(c => c.Name).IsRequired().HasMaxLength(200);
        modelBuilder.Entity<ContactMessage>().Property(c => c.Email).IsRequired().HasMaxLength(200);
        modelBuilder.Entity<ContactMessage>().Property(c => c.Message).IsRequired().HasMaxLength(2000);

        modelBuilder.Entity<UserNotificationSettings>().HasIndex(s => s.UserId).IsUnique();
        modelBuilder.Entity<UserNotificationSettings>()
            .HasOne(s => s.User)
            .WithMany()
            .HasForeignKey(s => s.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        // Product → SupplierProduct
        modelBuilder.Entity<SupplierProduct>()
            .HasOne(sp => sp.Product)
            .WithMany(p => p.SupplierProducts)
            .HasForeignKey(sp => sp.ProductId)
            .OnDelete(DeleteBehavior.Restrict);

        // MerchantsProfile → MasterOrder
        modelBuilder.Entity<MasterOrder>()
            .HasOne(o => o.Merchant)
            .WithMany(m => m.MasterOrders)
            .HasForeignKey(o => o.MerchantId)
            .OnDelete(DeleteBehavior.Restrict);

        // VoiceProcurementLog → MasterOrder (optional FK)
        modelBuilder.Entity<MasterOrder>()
            .HasOne(o => o.VoiceLog)
            .WithMany(v => v.MasterOrders)
            .HasForeignKey(o => o.VoiceLogID)
            .OnDelete(DeleteBehavior.SetNull)
            .IsRequired(false);

        // MasterOrder → SubOrder
        modelBuilder.Entity<SubOrder>()
            .HasOne(s => s.MasterOrder)
            .WithMany(o => o.SubOrders)
            .HasForeignKey(s => s.MasterId)
            .OnDelete(DeleteBehavior.Cascade);

        // SupplierProfile → SubOrder (optional — an open RFQ has no supplier
        // assigned yet; see SubOrder.SupplierId / Status.Bidding)
        modelBuilder.Entity<SubOrder>()
            .HasOne(s => s.Supplier)
            .WithMany(sup => sup.SubOrders)
            .HasForeignKey(s => s.SupplierId)
            .OnDelete(DeleteBehavior.Restrict)
            .IsRequired(false);

        // SubOrder → Bid (one RFQ line can receive many competing bids)
        modelBuilder.Entity<Bid>()
            .HasOne(b => b.SubOrder)
            .WithMany(s => s.Bids)
            .HasForeignKey(b => b.SubOrderId)
            .OnDelete(DeleteBehavior.Cascade);

        // SupplierProfile → Bid
        modelBuilder.Entity<Bid>()
            .HasOne(b => b.Supplier)
            .WithMany()
            .HasForeignKey(b => b.SupplierId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<Bid>().Property(b => b.Status).HasConversion<string>().HasMaxLength(20);
        modelBuilder.Entity<Bid>().Property(b => b.Price).HasPrecision(18, 4);

        modelBuilder.Entity<ReturnRequest>().Property(r => r.RequestedAmount).HasPrecision(18, 2);
        modelBuilder.Entity<ReturnRequest>().Property(r => r.ApprovedAmount).HasPrecision(18, 2);

        // Product → SubOrder (optional — see SubOrder.ProductId)
        modelBuilder.Entity<SubOrder>()
            .HasOne(s => s.Product)
            .WithMany()
            .HasForeignKey(s => s.ProductId)
            .OnDelete(DeleteBehavior.Restrict)
            .IsRequired(false);

        // MerchantsProfile → VoiceProcurementLog
        modelBuilder.Entity<VoiceProcurementLog>()
            .HasOne(v => v.Merchant)
            .WithMany(m => m.VoiceProcurementLogs)
            .HasForeignKey(v => v.MerchantId)
            .OnDelete(DeleteBehavior.Restrict);

        // VoiceProcurementLog → AIProcessing (1-to-1)
        modelBuilder.Entity<AIProcessing>()
            .HasOne(a => a.VoiceLog)
            .WithOne(v => v.AIProcessing)
            .HasForeignKey<AIProcessing>(a => a.VoiceLogId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}