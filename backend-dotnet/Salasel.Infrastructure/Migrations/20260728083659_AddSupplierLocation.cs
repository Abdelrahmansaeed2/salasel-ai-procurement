using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Salasel.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddSupplierLocation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ContactPhone",
                table: "SupplierProfiles",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<decimal>(
                name: "CoverageRadiusKm",
                table: "SupplierProfiles",
                type: "decimal(8,2)",
                precision: 8,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "LocationLat",
                table: "SupplierProfiles",
                type: "decimal(10,6)",
                precision: 10,
                scale: 6,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "LocationLng",
                table: "SupplierProfiles",
                type: "decimal(10,6)",
                precision: 10,
                scale: 6,
                nullable: false,
                defaultValue: 0m);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ContactPhone",
                table: "SupplierProfiles");

            migrationBuilder.DropColumn(
                name: "CoverageRadiusKm",
                table: "SupplierProfiles");

            migrationBuilder.DropColumn(
                name: "LocationLat",
                table: "SupplierProfiles");

            migrationBuilder.DropColumn(
                name: "LocationLng",
                table: "SupplierProfiles");
        }
    }
}
