using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Salasel.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class SetupReturnsTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ReturnRequests",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MasterOrderId = table.Column<int>(type: "int", nullable: false),
                    MerchantId = table.Column<int>(type: "int", nullable: false),
                    SupplierId = table.Column<int>(type: "int", nullable: true),
                    Reason = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PhotosJson = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ItemsJson = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    RequestedAmount = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    ApprovedAmount = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true),
                    Status = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ReturnRequests", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ReturnRequests_MasterOrders_MasterOrderId",
                        column: x => x.MasterOrderId,
                        principalTable: "MasterOrders",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ReturnRequests_MerchantsProfiles_MerchantId",
                        column: x => x.MerchantId,
                        principalTable: "MerchantsProfiles",
                        principalColumn: "MerchantID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ReturnRequests_SupplierProfiles_SupplierId",
                        column: x => x.SupplierId,
                        principalTable: "SupplierProfiles",
                        principalColumn: "SupplierID");
                });

            migrationBuilder.CreateIndex(
                name: "IX_ReturnRequests_MasterOrderId",
                table: "ReturnRequests",
                column: "MasterOrderId");

            migrationBuilder.CreateIndex(
                name: "IX_ReturnRequests_MerchantId",
                table: "ReturnRequests",
                column: "MerchantId");

            migrationBuilder.CreateIndex(
                name: "IX_ReturnRequests_SupplierId",
                table: "ReturnRequests",
                column: "SupplierId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ReturnRequests");
        }
    }
}
