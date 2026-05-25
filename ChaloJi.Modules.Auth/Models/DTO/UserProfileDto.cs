using System;

namespace ChaloJi.Modules.Auth.Models.DTO
{
    /// <summary>
    /// DTO for Driver Profile Response
    /// </summary>
    public class DriverProfileResponseDto
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public string KycStatus { get; set; } = string.Empty;
        public bool IsVerified { get; set; }
        public bool IsOnline { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public DateTime? VerifiedAt { get; set; }
        public string? RejectionReason { get; set; }

        // Related documents
        public AadhaarKycResponseDto? AadhaarKyc { get; set; }
        public PanCardResponseDto? PanCard { get; set; }
        public VehicleDetailResponseDto? VehicleDetail { get; set; }
        public DriverLicenseResponseDto? DriverLicense { get; set; }
    }

    /// <summary>
    /// DTO for Aadhaar KYC
    /// </summary>
    public class AadhaarKycDto
    {
        public string AadhaarNumber { get; set; } = string.Empty;
        public string? AadhaarFrontImageUrl { get; set; }
        public string? AadhaarBackImageUrl { get; set; }
    }

    public class AadhaarKycResponseDto
    {
        public Guid Id { get; set; }
        public string AadhaarNumber { get; set; } = string.Empty;
        public string? AadhaarFrontImageUrl { get; set; }
        public string? AadhaarBackImageUrl { get; set; }
        public bool IsOtpVerified { get; set; }
        public bool IsVerified { get; set; }
        public DateTime? VerifiedAt { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    /// <summary>
    /// DTO for PAN Card
    /// </summary>
    public class PanCardDto
    {
        public string PanNumber { get; set; } = string.Empty;
        public string? PanImageUrl { get; set; }
        public string? NameOnPan { get; set; }
        public DateTime? DateOfBirth { get; set; }
    }

    public class PanCardResponseDto
    {
        public Guid Id { get; set; }
        public string PanNumber { get; set; } = string.Empty;
        public string? PanImageUrl { get; set; }
        public string? NameOnPan { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public bool IsVerified { get; set; }
        public DateTime? VerifiedAt { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    /// <summary>
    /// DTO for Vehicle Details
    /// </summary>
    public class VehicleDetailDto
    {
        public string VehicleNumber { get; set; } = string.Empty;
        public int VehicleType { get; set; }
        public string VehicleName { get; set; } = string.Empty;
        public string? VehicleModel { get; set; }
        public string? VehicleColor { get; set; }
        public string? RcNumber { get; set; }
        public DateTime? RcExpiryDate { get; set; }
        public string? RcImageUrl { get; set; }
        public string InsurancePolicyNumber { get; set; } = string.Empty;
        public string? InsuranceCompanyName { get; set; }
        public DateTime? InsuranceExpiryDate { get; set; }
        public string? InsuranceImageUrl { get; set; }
        public string? FitnessCertificateNumber { get; set; }
        public DateTime? FitnessExpiryDate { get; set; }
        public string? FitnessImageUrl { get; set; }
        public string? PermitNumber { get; set; }
        public DateTime? PermitExpiryDate { get; set; }
        public string? PermitImageUrl { get; set; }
        public string? VehicleFrontImageUrl { get; set; }
        public string? VehicleSideImageUrl { get; set; }
    }

    public class VehicleDetailResponseDto
    {
        public Guid Id { get; set; }
        public string VehicleNumber { get; set; } = string.Empty;
        public string VehicleType { get; set; } = string.Empty;
        public string VehicleName { get; set; } = string.Empty;
        public string? VehicleModel { get; set; }
        public string? VehicleColor { get; set; }
        public string? RcNumber { get; set; }
        public DateTime? RcExpiryDate { get; set; }
        public string? RcImageUrl { get; set; }
        public string InsurancePolicyNumber { get; set; } = string.Empty;
        public string? InsuranceCompanyName { get; set; }
        public DateTime? InsuranceExpiryDate { get; set; }
        public string? InsuranceImageUrl { get; set; }
        public string? FitnessCertificateNumber { get; set; }
        public DateTime? FitnessExpiryDate { get; set; }
        public string? FitnessImageUrl { get; set; }
        public string? PermitNumber { get; set; }
        public DateTime? PermitExpiryDate { get; set; }
        public string? PermitImageUrl { get; set; }
        public string? VehicleFrontImageUrl { get; set; }
        public string? VehicleSideImageUrl { get; set; }
        public bool IsVerified { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }

    /// <summary>
    /// DTO for Driver License
    /// </summary>
    public class DriverLicenseDto
    {
        public string LicenseNumber { get; set; } = string.Empty;
        public string? LicenseClass { get; set; }
        public DateTime? IssueDate { get; set; }
        public DateTime ExpiryDate { get; set; }
        public string? IssuingAuthority { get; set; }
        public string? LicenseFrontImageUrl { get; set; }
        public string? LicenseBackImageUrl { get; set; }
    }

    public class DriverLicenseResponseDto
    {
        public Guid Id { get; set; }
        public string LicenseNumber { get; set; } = string.Empty;
        public string? LicenseClass { get; set; }
        public DateTime? IssueDate { get; set; }
        public DateTime ExpiryDate { get; set; }
        public string? IssuingAuthority { get; set; }
        public string? LicenseFrontImageUrl { get; set; }
        public string? LicenseBackImageUrl { get; set; }
        public bool IsVerified { get; set; }
        public DateTime? VerifiedAt { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    /// <summary>
    /// DTO for KYC Status
    /// </summary>
    public class KycStatusResponseDto
    {
        public Guid DriverProfileId { get; set; }
        public string Status { get; set; } = string.Empty;
        public bool IsProfileComplete { get; set; }
        public bool AadhaarVerified { get; set; }
        public bool PanVerified { get; set; }
        public bool VehicleVerified { get; set; }
        public bool LicenseVerified { get; set; }
        public DateTime LastUpdated { get; set; }
        public string? RejectionReason { get; set; }
    }

    public class VerifyOtpDto
    {
        public string OtpCode { get; set; } = string.Empty;
    }
}
