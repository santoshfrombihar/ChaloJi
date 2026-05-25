using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace ChaloJi.Modules.Auth.Models
{
    // ==========================================
    // DRIVER PROFILE MASTER
    // ==========================================
    public class DriverProfile
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        [Required]
        public Guid UserId { get; set; }

        [ForeignKey("UserId")]
        [JsonIgnore] // Prevents circular reference loops
        public User User { get; set; }

        // KYC Verification Status flags
        public KycStatus KycStatus { get; set; } = KycStatus.Pending;
        public bool IsVerified { get; set; } = false;
        public bool IsOnline { get; set; } = false;

        // Navigation properties for modular verification documents
        public AadhaarKyc? AadhaarKyc { get; set; }
        public PanCard? PanCard { get; set; }

        public string? LivePhotoUrl { get; set; }
        public DateTime? LivePhotoCapturedAt { get; set; }

        public VehicleDetail? VehicleDetail { get; set; }
        public DriverLicense? DriverLicense { get; set; }

        // System Auditing
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
        public DateTime? VerifiedAt { get; set; }
        public string? RejectionReason { get; set; }
    }

    // ==========================================
    // GID VERIFICATION OBJECT
    // ==========================================
    public class AadhaarKyc
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        public Guid DriverProfileId { get; set; }

        [ForeignKey("DriverProfileId")]
        [JsonIgnore] // Prevents loop crashes during serialization
        public DriverProfile DriverProfile { get; set; }

        [Required]
        [StringLength(12, MinimumLength = 12)]
        public string AadhaarNumber { get; set; } = string.Empty;

        public string? AadhaarFrontImageUrl { get; set; }
        public string? AadhaarBackImageUrl { get; set; }

        // Verification Handshake Process State
        public string? OtpCode { get; set; }
        public DateTime? OtpExpiry { get; set; }
        public bool IsOtpVerified { get; set; } = false;
        public DateTime? OtpVerifiedAt { get; set; }

        public bool IsVerified { get; set; } = false;
        public DateTime? VerifiedAt { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

    // ==========================================
    // TAX REGISTRATION SYSTEM
    // ==========================================
    public class PanCard
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        public Guid DriverProfileId { get; set; }

        [ForeignKey("DriverProfileId")]
        [JsonIgnore]
        public DriverProfile DriverProfile { get; set; }

        [Required]
        [StringLength(10, MinimumLength = 10)]
        [RegularExpression(@"^[A-Z]{5}[0-9]{4}[A-Z]{1}$",
            ErrorMessage = "Invalid PAN format. Example: ABCDE1234F")]
        public string PanNumber { get; set; } = string.Empty;

        public string? PanImageUrl { get; set; }

        public string? NameOnPan { get; set; }
        public DateTime? DateOfBirth { get; set; }

        public bool IsVerified { get; set; } = false;
        public DateTime? VerifiedAt { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

    // ==========================================
    // VEHICLE ASSET RECORDS
    // ==========================================
    public class VehicleDetail
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        public Guid DriverProfileId { get; set; }

        [ForeignKey("DriverProfileId")]
        [JsonIgnore]
        public DriverProfile DriverProfile { get; set; }

        [Required]
        public string VehicleNumber { get; set; } = string.Empty;

        [Required]
        public VehicleType VehicleType { get; set; }

        [Required]
        public string VehicleName { get; set; } = string.Empty;

        public string? VehicleModel { get; set; }
        public string? VehicleColor { get; set; }

        // Registration Certificates data
        public string? RcNumber { get; set; }
        public DateTime? RcExpiryDate { get; set; }
        public string? RcImageUrl { get; set; }

        // Legal Mandates: Insurance
        [Required]
        public string InsurancePolicyNumber { get; set; } = string.Empty;
        public string? InsuranceCompanyName { get; set; }
        public DateTime? InsuranceExpiryDate { get; set; }
        public string? InsuranceImageUrl { get; set; }

        // Compliance Certificate
        public string? FitnessCertificateNumber { get; set; }
        public DateTime? FitnessExpiryDate { get; set; }
        public string? FitnessImageUrl { get; set; }

        // Public Operations Authorization Permit
        public string? PermitNumber { get; set; }
        public DateTime? PermitExpiryDate { get; set; }
        public string? PermitImageUrl { get; set; }

        public string? VehicleFrontImageUrl { get; set; }
        public string? VehicleSideImageUrl { get; set; }

        public bool IsVerified { get; set; } = false;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
    }

    // ==========================================
    // REGULATORY AUTHORITY PERMITS
    // ==========================================
    public class DriverLicense
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        public Guid DriverProfileId { get; set; }

        [ForeignKey("DriverProfileId")]
        [JsonIgnore]
        public DriverProfile DriverProfile { get; set; }

        [Required]
        public string LicenseNumber { get; set; } = string.Empty;

        public string? LicenseClass { get; set; }
        public DateTime? IssueDate { get; set; }

        [Required]
        public DateTime ExpiryDate { get; set; }

        public string? IssuingAuthority { get; set; }
        public string? LicenseFrontImageUrl { get; set; }
        public string? LicenseBackImageUrl { get; set; }

        public bool IsVerified { get; set; } = false;
        public DateTime? VerifiedAt { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

    public enum KycStatus
    {
        Pending = 0,
        UnderReview = 1,
        Approved = 2,
        Rejected = 3,
        Expired = 4
    }

    public enum VehicleType
    {
        Auto = 0,
        Bike = 1,
        Car = 2,
        Van = 3,
        Bus = 4
    }
}