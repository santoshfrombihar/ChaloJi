using ChaloJi.Modules.Auth.Models;
using ChaloJi.Modules.Auth.Models.DTO;

namespace ChaloJi.Modules.Auth.Services.Interface
{
    /// <summary>
    /// User Profile Service Interface for managing driver profiles and KYC documents
    /// </summary>
    public interface IUserProfileService
    {
        /// <summary>
        /// Get driver profile by user ID
        /// </summary>
        Task<DriverProfileResponseDto?> GetDriverProfileAsync(Guid userId, CancellationToken cancellationToken = default);

        /// <summary>
        /// Create driver profile for a user
        /// </summary>
        Task<DriverProfileResponseDto> CreateDriverProfileAsync(Guid userId, CancellationToken cancellationToken = default);

        /// <summary>
        /// Update Aadhaar KYC details
        /// </summary>
        Task<AadhaarKycResponseDto> UpdateAadhaarKycAsync(Guid userId, AadhaarKycDto aadhaarDto, CancellationToken cancellationToken = default);

        /// <summary>
        /// Update PAN Card details
        /// </summary>
        Task<PanCardResponseDto> UpdatePanCardAsync(Guid userId, PanCardDto panCardDto, CancellationToken cancellationToken = default);

        /// <summary>
        /// Update Vehicle details
        /// </summary>
        Task<VehicleDetailResponseDto> UpdateVehicleDetailAsync(Guid userId, VehicleDetailDto vehicleDto, CancellationToken cancellationToken = default);

        /// <summary>
        /// Update Driver License details
        /// </summary>
        Task<DriverLicenseResponseDto> UpdateDriverLicenseAsync(Guid userId, DriverLicenseDto licenseDto, CancellationToken cancellationToken = default);

        /// <summary>
        /// Verify OTP for Aadhaar KYC
        /// </summary>
        Task<bool> VerifyAadhaarOtpAsync(Guid userId, string otpCode, CancellationToken cancellationToken = default);

        /// <summary>
        /// Submit driver profile for KYC verification
        /// </summary>
        Task<bool> SubmitForVerificationAsync(Guid userId, CancellationToken cancellationToken = default);

        /// <summary>
        /// Get KYC verification status
        /// </summary>
        Task<KycStatusResponseDto> GetKycStatusAsync(Guid userId, CancellationToken cancellationToken = default);

        /// <summary>
        /// Check if driver profile exists for user
        /// </summary>
        Task<bool> DriverProfileExistsAsync(Guid userId, CancellationToken cancellationToken = default);
    }
}
