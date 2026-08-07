using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Salasel.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class ExpandSupplierProfile : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Capacity",
                table: "SupplierWarehouses",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "WarehouseName",
                table: "SupplierWarehouses",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Address",
                table: "SupplierProfiles",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "BusinessType",
                table: "SupplierProfiles",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<bool>(
                name: "IsVatExempt",
                table: "SupplierProfiles",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "JobTitle",
                table: "SupplierProfiles",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "VatNumber",
                table: "SupplierProfiles",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Capacity",
                table: "SupplierWarehouses");

            migrationBuilder.DropColumn(
                name: "WarehouseName",
                table: "SupplierWarehouses");

            migrationBuilder.DropColumn(
                name: "Address",
                table: "SupplierProfiles");

            migrationBuilder.DropColumn(
                name: "BusinessType",
                table: "SupplierProfiles");

            migrationBuilder.DropColumn(
                name: "IsVatExempt",
                table: "SupplierProfiles");

            migrationBuilder.DropColumn(
                name: "JobTitle",
                table: "SupplierProfiles");

            migrationBuilder.DropColumn(
                name: "VatNumber",
                table: "SupplierProfiles");
        }
    }
}
