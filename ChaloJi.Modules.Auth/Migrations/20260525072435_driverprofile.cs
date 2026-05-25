using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ChaloJi.Modules.Auth.Migrations
{
    /// <inheritdoc />
    public partial class driverprofile : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "LicenseNumber",
                table: "DriverProfiles");

            migrationBuilder.DropColumn(
                name: "VehicleNumber",
                table: "DriverProfiles");

            migrationBuilder.DropColumn(
                name: "VehicleType",
                table: "DriverProfiles");

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "DriverProfiles",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<int>(
                name: "KycStatus",
                table: "DriverProfiles",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "LivePhotoCapturedAt",
                table: "DriverProfiles",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "LivePhotoUrl",
                table: "DriverProfiles",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "RejectionReason",
                table: "DriverProfiles",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAt",
                table: "DriverProfiles",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "VerifiedAt",
                table: "DriverProfiles",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "AadhaarKycs",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    DriverProfileId = table.Column<Guid>(type: "uuid", nullable: false),
                    AadhaarNumber = table.Column<string>(type: "character varying(12)", maxLength: 12, nullable: false),
                    AadhaarFrontImageUrl = table.Column<string>(type: "text", nullable: true),
                    AadhaarBackImageUrl = table.Column<string>(type: "text", nullable: true),
                    OtpCode = table.Column<string>(type: "text", nullable: true),
                    OtpExpiry = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    IsOtpVerified = table.Column<bool>(type: "boolean", nullable: false),
                    OtpVerifiedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    IsVerified = table.Column<bool>(type: "boolean", nullable: false),
                    VerifiedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AadhaarKycs", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AadhaarKycs_DriverProfiles_DriverProfileId",
                        column: x => x.DriverProfileId,
                        principalTable: "DriverProfiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "DriverLicenses",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    DriverProfileId = table.Column<Guid>(type: "uuid", nullable: false),
                    LicenseNumber = table.Column<string>(type: "text", nullable: false),
                    LicenseClass = table.Column<string>(type: "text", nullable: true),
                    IssueDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    ExpiryDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    IssuingAuthority = table.Column<string>(type: "text", nullable: true),
                    LicenseFrontImageUrl = table.Column<string>(type: "text", nullable: true),
                    LicenseBackImageUrl = table.Column<string>(type: "text", nullable: true),
                    IsVerified = table.Column<bool>(type: "boolean", nullable: false),
                    VerifiedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DriverLicenses", x => x.Id);
                    table.ForeignKey(
                        name: "FK_DriverLicenses_DriverProfiles_DriverProfileId",
                        column: x => x.DriverProfileId,
                        principalTable: "DriverProfiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PanCards",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    DriverProfileId = table.Column<Guid>(type: "uuid", nullable: false),
                    PanNumber = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    PanImageUrl = table.Column<string>(type: "text", nullable: true),
                    NameOnPan = table.Column<string>(type: "text", nullable: true),
                    DateOfBirth = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    IsVerified = table.Column<bool>(type: "boolean", nullable: false),
                    VerifiedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PanCards", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PanCards_DriverProfiles_DriverProfileId",
                        column: x => x.DriverProfileId,
                        principalTable: "DriverProfiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "VehicleDetails",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    DriverProfileId = table.Column<Guid>(type: "uuid", nullable: false),
                    VehicleNumber = table.Column<string>(type: "text", nullable: false),
                    VehicleType = table.Column<int>(type: "integer", nullable: false),
                    VehicleName = table.Column<string>(type: "text", nullable: false),
                    VehicleModel = table.Column<string>(type: "text", nullable: true),
                    VehicleColor = table.Column<string>(type: "text", nullable: true),
                    RcNumber = table.Column<string>(type: "text", nullable: true),
                    RcExpiryDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    RcImageUrl = table.Column<string>(type: "text", nullable: true),
                    InsurancePolicyNumber = table.Column<string>(type: "text", nullable: false),
                    InsuranceCompanyName = table.Column<string>(type: "text", nullable: true),
                    InsuranceExpiryDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    InsuranceImageUrl = table.Column<string>(type: "text", nullable: true),
                    FitnessCertificateNumber = table.Column<string>(type: "text", nullable: true),
                    FitnessExpiryDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    FitnessImageUrl = table.Column<string>(type: "text", nullable: true),
                    PermitNumber = table.Column<string>(type: "text", nullable: true),
                    PermitExpiryDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    PermitImageUrl = table.Column<string>(type: "text", nullable: true),
                    VehicleFrontImageUrl = table.Column<string>(type: "text", nullable: true),
                    VehicleSideImageUrl = table.Column<string>(type: "text", nullable: true),
                    IsVerified = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_VehicleDetails", x => x.Id);
                    table.ForeignKey(
                        name: "FK_VehicleDetails_DriverProfiles_DriverProfileId",
                        column: x => x.DriverProfileId,
                        principalTable: "DriverProfiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AadhaarKycs_DriverProfileId",
                table: "AadhaarKycs",
                column: "DriverProfileId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_DriverLicenses_DriverProfileId",
                table: "DriverLicenses",
                column: "DriverProfileId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_PanCards_DriverProfileId",
                table: "PanCards",
                column: "DriverProfileId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_VehicleDetails_DriverProfileId",
                table: "VehicleDetails",
                column: "DriverProfileId",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AadhaarKycs");

            migrationBuilder.DropTable(
                name: "DriverLicenses");

            migrationBuilder.DropTable(
                name: "PanCards");

            migrationBuilder.DropTable(
                name: "VehicleDetails");

            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "DriverProfiles");

            migrationBuilder.DropColumn(
                name: "KycStatus",
                table: "DriverProfiles");

            migrationBuilder.DropColumn(
                name: "LivePhotoCapturedAt",
                table: "DriverProfiles");

            migrationBuilder.DropColumn(
                name: "LivePhotoUrl",
                table: "DriverProfiles");

            migrationBuilder.DropColumn(
                name: "RejectionReason",
                table: "DriverProfiles");

            migrationBuilder.DropColumn(
                name: "UpdatedAt",
                table: "DriverProfiles");

            migrationBuilder.DropColumn(
                name: "VerifiedAt",
                table: "DriverProfiles");

            migrationBuilder.AddColumn<string>(
                name: "LicenseNumber",
                table: "DriverProfiles",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "VehicleNumber",
                table: "DriverProfiles",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "VehicleType",
                table: "DriverProfiles",
                type: "text",
                nullable: false,
                defaultValue: "");
        }
    }
}
