using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Salasel.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class Sprint0_ERD_Alignment : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "FraudPreventionLimits",
                columns: table => new
                {
                    RuleID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    RuleType = table.Column<int>(type: "int", nullable: false),
                    HardLimitValue = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FraudPreventionLimits", x => x.RuleID);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    UserID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FullName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Email = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PasswordHash = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Role = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.UserID);
                });

            migrationBuilder.CreateTable(
                name: "MerchantsProfiles",
                columns: table => new
                {
                    MerchantID = table.Column<int>(type: "int", nullable: false),
                    ShopName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    LocationLat = table.Column<decimal>(type: "decimal(10,6)", precision: 10, scale: 6, nullable: false),
                    LocationLng = table.Column<decimal>(type: "decimal(10,6)", precision: 10, scale: 6, nullable: false),
                    ContactPhone = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    IsVerified = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MerchantsProfiles", x => x.MerchantID);
                    table.ForeignKey(
                        name: "FK_MerchantsProfiles_Users_MerchantID",
                        column: x => x.MerchantID,
                        principalTable: "Users",
                        principalColumn: "UserID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SupplierProfiles",
                columns: table => new
                {
                    SupplierID = table.Column<int>(type: "int", nullable: false),
                    CompanyName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ReliabilityScore = table.Column<decimal>(type: "decimal(5,2)", precision: 5, scale: 2, nullable: false),
                    PaymentTerms = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    IsActiveForRouting = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SupplierProfiles", x => x.SupplierID);
                    table.ForeignKey(
                        name: "FK_SupplierProfiles_Users_SupplierID",
                        column: x => x.SupplierID,
                        principalTable: "Users",
                        principalColumn: "UserID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SystemAuditLogs",
                columns: table => new
                {
                    AuditID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    AdminUserID = table.Column<int>(type: "int", nullable: false),
                    ActionPerformed = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    TargetTable = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Timestamp = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SystemAuditLogs", x => x.AuditID);
                    table.ForeignKey(
                        name: "FK_SystemAuditLogs_Users_AdminUserID",
                        column: x => x.AdminUserID,
                        principalTable: "Users",
                        principalColumn: "UserID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "MerchantInventories",
                columns: table => new
                {
                    InventoryID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MerchantID = table.Column<int>(type: "int", nullable: false),
                    SKU = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CurrentQuantity = table.Column<int>(type: "int", nullable: false),
                    ReorderThreshold = table.Column<int>(type: "int", nullable: false),
                    LastUpdated = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MerchantInventories", x => x.InventoryID);
                    table.ForeignKey(
                        name: "FK_MerchantInventories_MerchantsProfiles_MerchantID",
                        column: x => x.MerchantID,
                        principalTable: "MerchantsProfiles",
                        principalColumn: "MerchantID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "VoiceProcurementLogs",
                columns: table => new
                {
                    LogID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MerchantID = table.Column<int>(type: "int", nullable: false),
                    RawAudioURL = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    TranscribedAmiyaText = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    LLMParsedJSON = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    NLPConfidenceScore = table.Column<decimal>(type: "decimal(5,4)", precision: 5, scale: 4, nullable: false),
                    ProcessedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_VoiceProcurementLogs", x => x.LogID);
                    table.ForeignKey(
                        name: "FK_VoiceProcurementLogs_MerchantsProfiles_MerchantID",
                        column: x => x.MerchantID,
                        principalTable: "MerchantsProfiles",
                        principalColumn: "MerchantID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SupplierCatalogs",
                columns: table => new
                {
                    CatalogID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SupplierID = table.Column<int>(type: "int", nullable: false),
                    SKU = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ProductName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    UnitPrice = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    StockAvailable = table.Column<int>(type: "int", nullable: false),
                    DeliveryLeadTime_Days = table.Column<int>(type: "int", nullable: false),
                    VectorEmbedding = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SupplierCatalogs", x => x.CatalogID);
                    table.ForeignKey(
                        name: "FK_SupplierCatalogs_SupplierProfiles_SupplierID",
                        column: x => x.SupplierID,
                        principalTable: "SupplierProfiles",
                        principalColumn: "SupplierID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "OrderTransactions",
                columns: table => new
                {
                    OrderID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MerchantID = table.Column<int>(type: "int", nullable: false),
                    VoiceLogID = table.Column<int>(type: "int", nullable: true),
                    TotalOrderCost = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    ApprovalStatus = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OrderTransactions", x => x.OrderID);
                    table.ForeignKey(
                        name: "FK_OrderTransactions_MerchantsProfiles_MerchantID",
                        column: x => x.MerchantID,
                        principalTable: "MerchantsProfiles",
                        principalColumn: "MerchantID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_OrderTransactions_VoiceProcurementLogs_VoiceLogID",
                        column: x => x.VoiceLogID,
                        principalTable: "VoiceProcurementLogs",
                        principalColumn: "LogID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "OrderSplits",
                columns: table => new
                {
                    SplitID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ParentOrderID = table.Column<int>(type: "int", nullable: false),
                    SupplierID = table.Column<int>(type: "int", nullable: false),
                    SKU = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    QuantityOrdered = table.Column<int>(type: "int", nullable: false),
                    SubTotalCost = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    FulfillmentStatus = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OrderSplits", x => x.SplitID);
                    table.ForeignKey(
                        name: "FK_OrderSplits_OrderTransactions_ParentOrderID",
                        column: x => x.ParentOrderID,
                        principalTable: "OrderTransactions",
                        principalColumn: "OrderID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_OrderSplits_SupplierProfiles_SupplierID",
                        column: x => x.SupplierID,
                        principalTable: "SupplierProfiles",
                        principalColumn: "SupplierID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_MerchantInventories_MerchantID",
                table: "MerchantInventories",
                column: "MerchantID");

            migrationBuilder.CreateIndex(
                name: "IX_OrderSplits_ParentOrderID",
                table: "OrderSplits",
                column: "ParentOrderID");

            migrationBuilder.CreateIndex(
                name: "IX_OrderSplits_SupplierID",
                table: "OrderSplits",
                column: "SupplierID");

            migrationBuilder.CreateIndex(
                name: "IX_OrderTransactions_MerchantID",
                table: "OrderTransactions",
                column: "MerchantID");

            migrationBuilder.CreateIndex(
                name: "IX_OrderTransactions_VoiceLogID",
                table: "OrderTransactions",
                column: "VoiceLogID");

            migrationBuilder.CreateIndex(
                name: "IX_SupplierCatalogs_SupplierID",
                table: "SupplierCatalogs",
                column: "SupplierID");

            migrationBuilder.CreateIndex(
                name: "IX_SystemAuditLogs_AdminUserID",
                table: "SystemAuditLogs",
                column: "AdminUserID");

            migrationBuilder.CreateIndex(
                name: "IX_VoiceProcurementLogs_MerchantID",
                table: "VoiceProcurementLogs",
                column: "MerchantID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "FraudPreventionLimits");

            migrationBuilder.DropTable(
                name: "MerchantInventories");

            migrationBuilder.DropTable(
                name: "OrderSplits");

            migrationBuilder.DropTable(
                name: "SupplierCatalogs");

            migrationBuilder.DropTable(
                name: "SystemAuditLogs");

            migrationBuilder.DropTable(
                name: "OrderTransactions");

            migrationBuilder.DropTable(
                name: "SupplierProfiles");

            migrationBuilder.DropTable(
                name: "VoiceProcurementLogs");

            migrationBuilder.DropTable(
                name: "MerchantsProfiles");

            migrationBuilder.DropTable(
                name: "Users");
        }
    }
}
