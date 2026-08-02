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

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // ─── Keys ───────────────────────────────────────────────────────────────
        modelBuilder.Entity<User>().HasKey(u => u.UserID);
        modelBuilder.Entity<MerchantsProfile>().HasKey(m => m.MerchantID);
        modelBuilder.Entity<SupplierProfile>().HasKey(s => s.SupplierID);
        modelBuilder.Entity<MerchantInventory>().HasKey(m => m.InventoryID);
        modelBuilder.Entity<MerchantDocument>().HasKey(d => d.Id);

        // ─── Unique Indexes ──────────────────────────────────────────────────────
        modelBuilder.Entity<User>().HasIndex(u => u.Email).IsUnique();
        modelBuilder.Entity<Product>().HasIndex(p => p.SKU).IsUnique();

        // ─── Enum → String Conversions ───────────────────────────────────────────
        modelBuilder.Entity<User>().Property(u => u.Role).HasConversion<string>().HasMaxLength(20);
        modelBuilder.Entity<MasterOrder>().Property(m => m.Status).HasConversion<string>().HasMaxLength(30);
        modelBuilder.Entity<MasterOrder>().Property(m => m.Source).HasConversion<string>().HasMaxLength(20);
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

        modelBuilder.Entity<Category>().Property(c => c.Name).HasMaxLength(100);

        modelBuilder.Entity<Product>().Property(p => p.Name).HasMaxLength(200);
        modelBuilder.Entity<Product>().Property(p => p.SKU).HasMaxLength(100);
        modelBuilder.Entity<Product>().Property(p => p.Unit).HasMaxLength(30);

        modelBuilder.Entity<AIProcessing>().Property(a => a.ModelUsed).HasMaxLength(60);

        // ─── Decimal Precision ───────────────────────────────────────────────────
        modelBuilder.Entity<MasterOrder>().Property(o => o.TotalAmount).HasPrecision(18, 4);

        modelBuilder.Entity<SubOrder>().Property(s => s.SubTotalAmount).HasPrecision(18, 4);

        modelBuilder.Entity<SupplierProduct>().Property(p => p.UnitPrice).HasPrecision(18, 4);

        modelBuilder.Entity<SupplierProfile>().Property(s => s.ReliabilityScore).HasPrecision(5, 2);
        modelBuilder.Entity<SupplierProfile>().Property(s => s.LocationLat).HasPrecision(10, 6);
        modelBuilder.Entity<SupplierProfile>().Property(s => s.LocationLng).HasPrecision(10, 6);
        modelBuilder.Entity<SupplierProfile>().Property(s => s.CoverageRadiusKm).HasPrecision(8, 2);

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

        // SupplierProfile → SubOrder
        modelBuilder.Entity<SubOrder>()
            .HasOne(s => s.Supplier)
            .WithMany(sup => sup.SubOrders)
            .HasForeignKey(s => s.SupplierId)
            .OnDelete(DeleteBehavior.Restrict);

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
