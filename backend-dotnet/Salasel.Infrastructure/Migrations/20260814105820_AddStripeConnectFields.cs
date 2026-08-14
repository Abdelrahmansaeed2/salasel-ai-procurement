using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Salasel.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddStripeConnectFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsStripeOnboardingComplete",
                table: "SupplierProfiles",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "StripeAccountId",
                table: "SupplierProfiles",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "StripeTransferId",
                table: "SubOrders",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "StripeTransferReversalId",
                table: "SubOrders",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsStripeOnboardingComplete",
                table: "SupplierProfiles");

            migrationBuilder.DropColumn(
                name: "StripeAccountId",
                table: "SupplierProfiles");

            migrationBuilder.DropColumn(
                name: "StripeTransferId",
                table: "SubOrders");

            migrationBuilder.DropColumn(
                name: "StripeTransferReversalId",
                table: "SubOrders");
        }
    }
}
