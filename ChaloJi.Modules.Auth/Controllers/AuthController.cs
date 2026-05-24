using ChaloJi.Modules.Auth.Exceptions;
using ChaloJi.Modules.Auth.Models.DTO;
using ChaloJi.Modules.Auth.Services.Interface;
using ChaloJi.Modules.Auth.Validators;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.ComponentModel.DataAnnotations;

namespace ChaloJi.Modules.Auth.Controllers
{
    /// <summary>
    /// Authentication Controller
    /// Handles user registration, login, and related authentication operations
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    [Produces("application/json")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly ILogger<AuthController> _logger;

        public AuthController(IAuthService authService, ILogger<AuthController> logger)
        {
            _authService = authService ?? throw new ArgumentNullException(nameof(authService));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        /// <summary>
        /// Register a new user account
        /// </summary>
        /// <param name="registerDto">User registration details</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Registration response with user details</returns>
        /// <response code="201">User registered successfully</response>
        /// <response code="400">Invalid input or user already exists</response>
        /// <response code="500">Internal server error</response>
        [HttpPost("register")]
        [ProducesResponseType(typeof(ApiResponse<RegisterResponseDto>), StatusCodes.Status201Created)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> Register(
            [FromBody] RegisterDto registerDto,
            CancellationToken cancellationToken = default)
        {
            try
            {
                // Validate input
                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors);
                    return BadRequest(ApiResponse<object>.ErrorResponse(
                        "Validation failed",
                        "VALIDATION_ERROR",
                        new { errors = errors.Select(e => e.ErrorMessage) }
                    ));
                }

                // Additional validation
                var validationResult = RegisterDtoValidator.Validate(registerDto);
                if (validationResult != null)
                {
                    return BadRequest(ApiResponse<object>.ErrorResponse(
                        validationResult.ErrorMessage,
                        "VALIDATION_ERROR"
                    ));
                }

                var result = await _authService.RegisterUserAsync(registerDto, cancellationToken);

                _logger.LogInformation("User registration successful: {Email}", registerDto.Email);

                return CreatedAtAction(
                    nameof(Register),
                    ApiResponse<RegisterResponseDto>.SuccessResponse(
                        result,
                        "User registered successfully"
                    )
                );
            }
            catch (AuthException authEx)
            {
                _logger.LogWarning("Authentication error during registration: {Message}", authEx.Message);
                return BadRequest(ApiResponse<object>.ErrorResponse(authEx.Message, authEx.ErrorCode));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during user registration");
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    ApiResponse<object>.ErrorResponse(
                        "An unexpected error occurred during registration",
                        "INTERNAL_ERROR"
                    )
                );
            }
        }

        /// <summary>
        /// Authenticate user and receive authentication token
        /// </summary>
        /// <param name="loginDto">User login credentials</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Authentication token and user information</returns>
        /// <response code="200">Login successful</response>
        /// <response code="400">Invalid credentials or missing input</response>
        /// <response code="401">Unauthorized - Invalid credentials</response>
        /// <response code="500">Internal server error</response>
        [HttpPost("login")]
        [ProducesResponseType(typeof(ApiResponse<LoginResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> Login(
            [FromBody] LoginDto loginDto,
            CancellationToken cancellationToken = default)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors);
                    return BadRequest(ApiResponse<object>.ErrorResponse(
                        "Validation failed",
                        "VALIDATION_ERROR",
                        new { errors = errors.Select(e => e.ErrorMessage) }
                    ));
                }

                if (string.IsNullOrWhiteSpace(loginDto?.Email) || string.IsNullOrWhiteSpace(loginDto?.Password))
                {
                    return BadRequest(ApiResponse<object>.ErrorResponse(
                        "Email and password are required",
                        "MISSING_CREDENTIALS"
                    ));
                }

                var result = await _authService.LoginUserAsync(loginDto, cancellationToken);

                _logger.LogInformation("User login successful: {Email}", loginDto.Email);

                return Ok(ApiResponse<LoginResponseDto>.SuccessResponse(
                    result,
                    "Login successful"
                ));
            }
            catch (AuthException authEx)
            {
                _logger.LogWarning("Authentication error during login: {Message}", authEx.Message);

                // Return 401 for invalid credentials, 400 for other auth errors
                var statusCode = authEx.ErrorCode == "INVALID_CREDENTIALS"
                    ? StatusCodes.Status401Unauthorized
                    : StatusCodes.Status400BadRequest;

                return StatusCode(
                    statusCode,
                    ApiResponse<object>.ErrorResponse(authEx.Message, authEx.ErrorCode)
                );
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during user login");
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    ApiResponse<object>.ErrorResponse(
                        "An unexpected error occurred during login",
                        "INTERNAL_ERROR"
                    )
                );
            }
        }

        /// <summary>
        /// Check if email is available for registration
        /// </summary>
        /// <param name="email">Email address to check</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Availability status of email</returns>
        /// <response code="200">Email availability checked</response>
        /// <response code="400">Invalid email format</response>
        /// <response code="500">Internal server error</response>
        [HttpGet("check-email")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> CheckEmailAvailability(
            [FromQuery] string email,
            CancellationToken cancellationToken = default)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(email))
                {
                    return BadRequest(ApiResponse<object>.ErrorResponse(
                        "Email cannot be empty",
                        "INVALID_INPUT"
                    ));
                }

                var isRegistered = await _authService.IsEmailRegisteredAsync(email, cancellationToken);

                return Ok(ApiResponse<object>.SuccessResponse(
                    new { email, isAvailable = !isRegistered },
                    "Email availability checked"
                ));
            }
            catch (AuthException authEx)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse(authEx.Message, authEx.ErrorCode));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking email availability");
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    ApiResponse<object>.ErrorResponse(
                        "An error occurred while checking email availability",
                        "INTERNAL_ERROR"
                    )
                );
            }
        }
    }
}
