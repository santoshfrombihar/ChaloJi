using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ChaloJi.Modules.Auth.Migrations
{
    /// <inheritdoc />
    public partial class driverprofileupgrade : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_VehicleDetails_VehicleNumber",
                table: "VehicleDetails",
                column: "VehicleNumber",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_PanCards_PanNumber",
                table: "PanCards",
                column: "PanNumber",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_DriverLicenses_LicenseNumber",
                table: "DriverLicenses",
                column: "LicenseNumber",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_AadhaarKycs_AadhaarNumber",
                table: "AadhaarKycs",
                column: "AadhaarNumber",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_VehicleDetails_VehicleNumber",
                table: "VehicleDetails");

            migrationBuilder.DropIndex(
                name: "IX_PanCards_PanNumber",
                table: "PanCards");

            migrationBuilder.DropIndex(
                name: "IX_DriverLicenses_LicenseNumber",
                table: "DriverLicenses");

            migrationBuilder.DropIndex(
                name: "IX_AadhaarKycs_AadhaarNumber",
                table: "AadhaarKycs");
        }
    }
}
