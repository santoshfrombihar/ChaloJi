using ChaloJi.Modules.Auth.Exceptions;
using ChaloJi.Modules.Auth.Models.DTO;
using ChaloJi.Modules.Auth.Services.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Security.Claims;

namespace ChaloJi.Modules.Auth.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    [Produces("application/json")]
    [Authorize]
    public class UserProfileController : ControllerBase
    {
        private readonly IUserProfileService _userProfileService;
        private readonly ILogger<UserProfileController> _logger;

        public UserProfileController(IUserProfileService userProfileService, ILogger<UserProfileController> logger)
        {
            _userProfileService = userProfileService ?? throw new ArgumentNullException(nameof(userProfileService));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        [HttpGet("profile")]
        [ProducesResponseType(typeof(ApiResponse<DriverProfileResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> GetDriverProfile(CancellationToken cancellationToken = default)
        {
            try
            {
                var userId = GetCurrentUserId();
                var profile = await _userProfileService.GetDriverProfileAsync(userId, cancellationToken);

                if (profile == null)
                    return NotFound(ApiResponse<object>.ErrorResponse("Driver profile not found.", "PROFILE_NOT_FOUND"));

                return Ok(ApiResponse<DriverProfileResponseDto>.SuccessResponse(profile, "Profile retrieved successfully"));
            }
            catch (AuthException authEx)
            {
                _logger.LogWarning("Authorization error retrieving profile: {Message}", authEx.Message);
                return BadRequest(ApiResponse<object>.ErrorResponse(authEx.Message, authEx.ErrorCode));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving driver profile");
                return StatusCode(StatusCodes.Status500InternalServerError,
                    ApiResponse<object>.ErrorResponse("An error occurred while retrieving the profile.", "RETRIEVAL_ERROR"));
            }
        }

        [HttpPost("profile/create")]
        [ProducesResponseType(typeof(ApiResponse<DriverProfileResponseDto>), StatusCodes.Status201Created)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status409Conflict)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> CreateDriverProfile(CancellationToken cancellationToken = default)
        {
            try
            {
                var userId = GetCurrentUserId();
                var profile = await _userProfileService.CreateDriverProfileAsync(userId, cancellationToken);

                _logger.LogInformation("Driver profile created for user {UserId}", userId);

                return CreatedAtAction(nameof(GetDriverProfile),
                    ApiResponse<DriverProfileResponseDto>.SuccessResponse(profile, "Profile created successfully"));
            }
            catch (AuthException authEx)
            {
                _logger.LogWarning("Authorization error creating profile: {Message}", authEx.Message);
                return authEx.ErrorCode == "PROFILE_EXISTS"
                    ? Conflict(ApiResponse<object>.ErrorResponse(authEx.Message, authEx.ErrorCode))
                    : BadRequest(ApiResponse<object>.ErrorResponse(authEx.Message, authEx.ErrorCode));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating driver profile");
                return StatusCode(StatusCodes.Status500InternalServerError,
                    ApiResponse<object>.ErrorResponse("An error occurred while creating the profile.", "CREATION_ERROR"));
            }
        }

        [HttpPut("aadhaar-kyc")]
        public async Task<IActionResult> UpdateAadhaarKyc([FromBody] AadhaarKycDto aadhaarDto, CancellationToken cancellationToken = default)
        {
            try
            {
                // [ApiController] simplifies this by doing automated validation on input schema!
                var userId = GetCurrentUserId();
                var result = await _userProfileService.UpdateAadhaarKycAsync(userId, aadhaarDto, cancellationToken);

                _logger.LogInformation("Aadhaar KYC updated for user {UserId}", userId);
                return Ok(ApiResponse<AadhaarKycResponseDto>.SuccessResponse(result, "Aadhaar KYC updated successfully"));
            }
            catch (AuthException authEx)
            {
                _logger.LogWarning("Authorization error updating Aadhaar KYC: {Message}", authEx.Message);
                return BadRequest(ApiResponse<object>.ErrorResponse(authEx.Message, authEx.ErrorCode));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating Aadhaar KYC");
                return StatusCode(StatusCodes.Status500InternalServerError,
                    ApiResponse<object>.ErrorResponse("An error occurred while updating Aadhaar KYC.", "UPDATE_ERROR"));
            }
        }

        [HttpPut("pan-card")]
        public async Task<IActionResult> UpdatePanCard([FromBody] PanCardDto panCardDto, CancellationToken cancellationToken = default)
        {
            try
            {
                var userId = GetCurrentUserId();
                var result = await _userProfileService.UpdatePanCardAsync(userId, panCardDto, cancellationToken);

                _logger.LogInformation("PAN Card updated for user {UserId}", userId);
                return Ok(ApiResponse<PanCardResponseDto>.SuccessResponse(result, "PAN Card updated successfully"));
            }
            catch (AuthException authEx)
            {
                _logger.LogWarning("Authorization error updating PAN Card: {Message}", authEx.Message);
                return BadRequest(ApiResponse<object>.ErrorResponse(authEx.Message, authEx.ErrorCode));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating PAN Card");
                return StatusCode(StatusCodes.Status500InternalServerError,
                    ApiResponse<object>.ErrorResponse("An error occurred while updating PAN Card.", "UPDATE_ERROR"));
            }
        }

        [HttpPut("vehicle-details")]
        public async Task<IActionResult> UpdateVehicleDetails([FromBody] VehicleDetailDto vehicleDto, CancellationToken cancellationToken = default)
        {
            try
            {
                var userId = GetCurrentUserId();
                var result = await _userProfileService.UpdateVehicleDetailAsync(userId, vehicleDto, cancellationToken);

                _logger.LogInformation("Vehicle details updated for user {UserId}", userId);
                return Ok(ApiResponse<VehicleDetailResponseDto>.SuccessResponse(result, "Vehicle details updated successfully"));
            }
            catch (AuthException authEx)
            {
                _logger.LogWarning("Authorization error updating vehicle details: {Message}", authEx.Message);
                return BadRequest(ApiResponse<object>.ErrorResponse(authEx.Message, authEx.ErrorCode));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating vehicle details");
                return StatusCode(StatusCodes.Status500InternalServerError,
                    ApiResponse<object>.ErrorResponse("An error occurred while updating vehicle details.", "UPDATE_ERROR"));
            }
        }

        [HttpPut("driver-license")]
        public async Task<IActionResult> UpdateDriverLicense([FromBody] DriverLicenseDto licenseDto, CancellationToken cancellationToken = default)
        {
            try
            {
                var userId = GetCurrentUserId();
                var result = await _userProfileService.UpdateDriverLicenseAsync(userId, licenseDto, cancellationToken);

                _logger.LogInformation("Driver license updated for user {UserId}", userId);
                return Ok(ApiResponse<DriverLicenseResponseDto>.SuccessResponse(result, "Driver license updated successfully"));
            }
            catch (AuthException authEx)
            {
                _logger.LogWarning("Authorization error updating driver license: {Message}", authEx.Message);
                return BadRequest(ApiResponse<object>.ErrorResponse(authEx.Message, authEx.ErrorCode));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating driver license");
                return StatusCode(StatusCodes.Status500InternalServerError,
                    ApiResponse<object>.ErrorResponse("An error occurred while updating driver license.", "UPDATE_ERROR"));
            }
        }

        [HttpPost("verify-aadhaar-otp")]
        public async Task<IActionResult> VerifyAadhaarOtp([FromBody] VerifyOtpDto verifyOtpDto, CancellationToken cancellationToken = default)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(verifyOtpDto?.OtpCode))
                    return BadRequest(ApiResponse<object>.ErrorResponse("OTP code is required", "INVALID_INPUT"));

                var userId = GetCurrentUserId();
                await _userProfileService.VerifyAadhaarOtpAsync(userId, verifyOtpDto.OtpCode, cancellationToken);

                _logger.LogInformation("Aadhaar OTP verified for user {UserId}", userId);
                return Ok(ApiResponse<object>.SuccessResponse(new { success = true }, "OTP verified successfully"));
            }
            catch (AuthException authEx)
            {
                _logger.LogWarning("Authorization error verifying OTP: {Message}", authEx.Message);
                return BadRequest(ApiResponse<object>.ErrorResponse(authEx.Message, authEx.ErrorCode));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error verifying OTP");
                return StatusCode(StatusCodes.Status500InternalServerError,
                    ApiResponse<object>.ErrorResponse("An error occurred while verifying OTP.", "VERIFICATION_ERROR"));
            }
        }

        [HttpPost("submit-for-verification")]
        public async Task<IActionResult> SubmitForVerification(CancellationToken cancellationToken = default)
        {
            try
            {
                var userId = GetCurrentUserId();
                await _userProfileService.SubmitForVerificationAsync(userId, cancellationToken);

                _logger.LogInformation("Driver profile submitted for verification: {UserId}", userId);
                return Ok(ApiResponse<object>.SuccessResponse(new { success = true }, "Profile submitted for verification successfully"));
            }
            catch (AuthException authEx)
            {
                _logger.LogWarning("Authorization error submitting profile: {Message}", authEx.Message);
                return BadRequest(ApiResponse<object>.ErrorResponse(authEx.Message, authEx.ErrorCode));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error submitting profile for verification");
                return StatusCode(StatusCodes.Status500InternalServerError,
                    ApiResponse<object>.ErrorResponse("An error occurred while submitting profile.", "SUBMISSION_ERROR"));
            }
        }

        [HttpGet("kyc-status")]
        public async Task<IActionResult> GetKycStatus(CancellationToken cancellationToken = default)
        {
            try
            {
                var userId = GetCurrentUserId();
                var status = await _userProfileService.GetKycStatusAsync(userId, cancellationToken);

                return Ok(ApiResponse<KycStatusResponseDto>.SuccessResponse(status, "KYC status retrieved successfully"));
            }
            catch (AuthException authEx)
            {
                _logger.LogWarning("Authorization error retrieving KYC status: {Message}", authEx.Message);
                return authEx.ErrorCode == "PROFILE_NOT_FOUND"
                    ? NotFound(ApiResponse<object>.ErrorResponse(authEx.Message, authEx.ErrorCode))
                    : BadRequest(ApiResponse<object>.ErrorResponse(authEx.Message, authEx.ErrorCode));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving KYC status");
                return StatusCode(StatusCodes.Status500InternalServerError,
                    ApiResponse<object>.ErrorResponse("An error occurred while retrieving KYC status.", "STATUS_RETRIEVAL_ERROR"));
            }
        }

        private Guid GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null || !Guid.TryParse(userIdClaim.Value, out var userId))
                throw new AuthException("User ID not found in token.", "INVALID_TOKEN");

            return userId;
        }
    }
}