using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Salasel.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class SyncMissingModels : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsSetupCompleted",
                table: "Users",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "TokenVersion",
                table: "Users",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AlterColumn<int>(
                name: "SupplierId",
                table: "SubOrders",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AddColumn<DateTime>(
                name: "AcceptedAt",
                table: "SubOrders",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "DeliveredAt",
                table: "SubOrders",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DriverName",
                table: "SubOrders",
                type: "nvarchar(150)",
                maxLength: 150,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DriverPhone",
                table: "SubOrders",
                type: "nvarchar(30)",
                maxLength: 30,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ProductId",
                table: "SubOrders",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "ReceiptConfirmedAt",
                table: "SubOrders",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "ShippedAt",
                table: "SubOrders",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Address",
                table: "MerchantsProfiles",
                type: "nvarchar(300)",
                maxLength: 300,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "BusinessCity",
                table: "MerchantsProfiles",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Category",
                table: "MerchantsProfiles",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "CrNumber",
                table: "MerchantsProfiles",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Governorate",
                table: "MerchantsProfiles",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "OwnerIdentityNumber",
                table: "MerchantsProfiles",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "OwnerName",
                table: "MerchantsProfiles",
                type: "nvarchar(150)",
                maxLength: 150,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "StoreSize",
                table: "MerchantsProfiles",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "VerificationStatus",
                table: "MerchantsProfiles",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<DateTime>(
                name: "LowStockAlertDismissedAt",
                table: "MerchantInventories",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "LowStockAlertDismissedAtQty",
                table: "MerchantInventories",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "PaidAt",
                table: "MasterOrders",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PaymentMethod",
                table: "MasterOrders",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PaymentReference",
                table: "MasterOrders",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PaymentStatus",
                table: "MasterOrders",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateTable(
                name: "Bids",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SubOrderId = table.Column<int>(type: "int", nullable: false),
                    SupplierId = table.Column<int>(type: "int", nullable: false),
                    Price = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    Notes = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Status = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    SubmittedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    DecidedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Bids", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Bids_SubOrders_SubOrderId",
                        column: x => x.SubOrderId,
                        principalTable: "SubOrders",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Bids_SupplierProfiles_SupplierId",
                        column: x => x.SupplierId,
                        principalTable: "SupplierProfiles",
                        principalColumn: "SupplierID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "MerchantDocuments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MerchantId = table.Column<int>(type: "int", nullable: false),
                    DocumentType = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    FileUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    UploadedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MerchantDocuments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MerchantDocuments_MerchantsProfiles_MerchantId",
                        column: x => x.MerchantId,
                        principalTable: "MerchantsProfiles",
                        principalColumn: "MerchantID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_SubOrders_ProductId",
                table: "SubOrders",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_Bids_SubOrderId",
                table: "Bids",
                column: "SubOrderId");

            migrationBuilder.CreateIndex(
                name: "IX_Bids_SupplierId",
                table: "Bids",
                column: "SupplierId");

            migrationBuilder.CreateIndex(
                name: "IX_MerchantDocuments_MerchantId",
                table: "MerchantDocuments",
                column: "MerchantId");

            migrationBuilder.AddForeignKey(
                name: "FK_SubOrders_Products_ProductId",
                table: "SubOrders",
                column: "ProductId",
                principalTable: "Products",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_SubOrders_Products_ProductId",
                table: "SubOrders");

            migrationBuilder.DropTable(
                name: "Bids");

            migrationBuilder.DropTable(
                name: "MerchantDocuments");

            migrationBuilder.DropIndex(
                name: "IX_SubOrders_ProductId",
                table: "SubOrders");

            migrationBuilder.DropColumn(
                name: "IsSetupCompleted",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "TokenVersion",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "AcceptedAt",
                table: "SubOrders");

            migrationBuilder.DropColumn(
                name: "DeliveredAt",
                table: "SubOrders");

            migrationBuilder.DropColumn(
                name: "DriverName",
                table: "SubOrders");

            migrationBuilder.DropColumn(
                name: "DriverPhone",
                table: "SubOrders");

            migrationBuilder.DropColumn(
                name: "ProductId",
                table: "SubOrders");

            migrationBuilder.DropColumn(
                name: "ReceiptConfirmedAt",
                table: "SubOrders");

            migrationBuilder.DropColumn(
                name: "ShippedAt",
                table: "SubOrders");

            migrationBuilder.DropColumn(
                name: "Address",
                table: "MerchantsProfiles");

            migrationBuilder.DropColumn(
                name: "BusinessCity",
                table: "MerchantsProfiles");

            migrationBuilder.DropColumn(
                name: "Category",
                table: "MerchantsProfiles");

            migrationBuilder.DropColumn(
                name: "CrNumber",
                table: "MerchantsProfiles");

            migrationBuilder.DropColumn(
                name: "Governorate",
                table: "MerchantsProfiles");

            migrationBuilder.DropColumn(
                name: "OwnerIdentityNumber",
                table: "MerchantsProfiles");

            migrationBuilder.DropColumn(
                name: "OwnerName",
                table: "MerchantsProfiles");

            migrationBuilder.DropColumn(
                name: "StoreSize",
                table: "MerchantsProfiles");

            migrationBuilder.DropColumn(
                name: "VerificationStatus",
                table: "MerchantsProfiles");

            migrationBuilder.DropColumn(
                name: "LowStockAlertDismissedAt",
                table: "MerchantInventories");

            migrationBuilder.DropColumn(
                name: "LowStockAlertDismissedAtQty",
                table: "MerchantInventories");

            migrationBuilder.DropColumn(
                name: "PaidAt",
                table: "MasterOrders");

            migrationBuilder.DropColumn(
                name: "PaymentMethod",
                table: "MasterOrders");

            migrationBuilder.DropColumn(
                name: "PaymentReference",
                table: "MasterOrders");

            migrationBuilder.DropColumn(
                name: "PaymentStatus",
                table: "MasterOrders");

            migrationBuilder.AlterColumn<int>(
                name: "SupplierId",
                table: "SubOrders",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);
        }
    }
}
