using Microsoft.EntityFrameworkCore;
using Salasel.Domain.Entities;

namespace Salasel.Infrastructure.Data;

public class SalaselDbContext : DbContext
{
    public SalaselDbContext(DbContextOptions<SalaselDbContext> options) : base(options) { }

    public DbSet<User> Users { get; set; } = null!;
    public DbSet<MerchantsProfile> MerchantsProfiles { get; set; } = null!;
    public DbSet<SupplierProfile> SupplierProfiles { get; set; } = null!;
    public DbSet<SystemAuditLog> SystemAuditLogs { get; set; } = null!;
    public DbSet<MerchantInventory> MerchantInventories { get; set; } = null!;
    public DbSet<VoiceProcurementLog> VoiceProcurementLogs { get; set; } = null!;
    public DbSet<OrderTransaction> OrderTransactions { get; set; } = null!;
    public DbSet<OrderSplit> OrderSplits { get; set; } = null!;
    public DbSet<SupplierCatalog> SupplierCatalogs { get; set; } = null!;
    public DbSet<FraudPreventionLimit> FraudPreventionLimits { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // 1-to-1 relationships for profiles
        modelBuilder.Entity<User>()
            .Property(u => u.Role)
            .HasConversion<string>()
            .HasMaxLength(20);

        modelBuilder.Entity<User>()
            .HasIndex(u => u.Email)
            .IsUnique();

        modelBuilder.Entity<MerchantsProfile>()
            .HasKey(m => m.MerchantID);
        modelBuilder.Entity<MerchantsProfile>()
            .HasOne(m => m.User)
            .WithOne(u => u.MerchantsProfile)
            .HasForeignKey<MerchantsProfile>(m => m.MerchantID);

        modelBuilder.Entity<SupplierProfile>()
            .HasKey(s => s.SupplierID);
        modelBuilder.Entity<SupplierProfile>()
            .HasOne(s => s.User)
            .WithOne(u => u.SupplierProfile)
            .HasForeignKey<SupplierProfile>(s => s.SupplierID);

        // Primary Keys
        modelBuilder.Entity<SystemAuditLog>().HasKey(a => a.AuditID);
        modelBuilder.Entity<MerchantInventory>().HasKey(i => i.InventoryID);
        modelBuilder.Entity<VoiceProcurementLog>().HasKey(v => v.LogID);
        modelBuilder.Entity<OrderTransaction>().HasKey(o => o.OrderID);
        modelBuilder.Entity<OrderSplit>().HasKey(o => o.SplitID);
        modelBuilder.Entity<SupplierCatalog>().HasKey(c => c.CatalogID);
        modelBuilder.Entity<FraudPreventionLimit>().HasKey(f => f.RuleID);

        // Foreign keys and relationships
        modelBuilder.Entity<SystemAuditLog>()
            .HasOne(s => s.AdminUser)
            .WithMany(u => u.SystemAuditLogs)
            .HasForeignKey(s => s.AdminUserID);

        modelBuilder.Entity<MerchantInventory>()
            .HasOne(i => i.Merchant)
            .WithMany(m => m.Inventories)
            .HasForeignKey(i => i.MerchantID);

        modelBuilder.Entity<VoiceProcurementLog>()
            .HasOne(v => v.Merchant)
            .WithMany(m => m.VoiceProcurementLogs)
            .HasForeignKey(v => v.MerchantID);

        modelBuilder.Entity<OrderTransaction>()
            .HasOne(o => o.Merchant)
            .WithMany(m => m.OrderTransactions)
            .HasForeignKey(o => o.MerchantID)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<OrderTransaction>()
            .HasOne(o => o.VoiceLog)
            .WithMany(v => v.OrderTransactions)
            .HasForeignKey(o => o.VoiceLogID)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<OrderSplit>()
            .HasOne(s => s.ParentOrder)
            .WithMany(o => o.OrderSplits)
            .HasForeignKey(s => s.ParentOrderID)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<OrderSplit>()
            .HasOne(s => s.Supplier)
            .WithMany(sup => sup.OrderSplits)
            .HasForeignKey(s => s.SupplierID)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<SupplierCatalog>()
            .HasOne(c => c.Supplier)
            .WithMany(s => s.SupplierCatalogs)
            .HasForeignKey(c => c.SupplierID);

        // Precisions
        modelBuilder.Entity<OrderTransaction>().Property(o => o.TotalOrderCost).HasPrecision(18, 4);
        modelBuilder.Entity<OrderSplit>().Property(s => s.SubTotalCost).HasPrecision(18, 4);
        modelBuilder.Entity<SupplierCatalog>().Property(c => c.UnitPrice).HasPrecision(18, 4);
        modelBuilder.Entity<SupplierProfile>().Property(s => s.ReliabilityScore).HasPrecision(5, 2);
        modelBuilder.Entity<MerchantsProfile>().Property(m => m.LocationLat).HasPrecision(10, 6);
        modelBuilder.Entity<MerchantsProfile>().Property(m => m.LocationLng).HasPrecision(10, 6);
        modelBuilder.Entity<VoiceProcurementLog>().Property(v => v.NLPConfidenceScore).HasPrecision(5, 4);
        modelBuilder.Entity<FraudPreventionLimit>().Property(f => f.HardLimitValue).HasPrecision(18, 4);
    }
}