using ChaloJi.Modules.Auth.Data;
using ChaloJi.Modules.Auth.Exceptions;
using ChaloJi.Modules.Auth.Models;
using ChaloJi.Modules.Auth.Models.DTO;
using ChaloJi.Modules.Auth.Models.Enum;
using ChaloJi.Modules.Auth.Services.Interface;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using BCrypt.Net;

namespace ChaloJi.Modules.Auth.Services.Class
{
    /// <summary>
    /// Authentication service implementation
    /// </summary>
    public class AuthService : IAuthService
    {
        private readonly AuthDbContext _authDb;
        private readonly ILogger<AuthService> _logger;
        private readonly IJwtTokenService _jwtTokenService;

        public AuthService(AuthDbContext authDb, ILogger<AuthService> logger, IJwtTokenService jwtTokenService)
        {
            _authDb = authDb ?? throw new ArgumentNullException(nameof(authDb));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            _jwtTokenService = jwtTokenService ?? throw new ArgumentNullException(nameof(jwtTokenService));
        }

        /// <summary>
        /// Registers a new user with validation
        /// </summary>
        public async Task<RegisterResponseDto> RegisterUserAsync(RegisterDto registerDto, CancellationToken cancellationToken = default)
        {
            try
            {
                // Validate input
                if (registerDto == null)
                    throw new AuthException("Registration data cannot be null.", "INVALID_INPUT");

                // Check if user already exists
                var existingUser = await _authDb.Users.FirstOrDefaultAsync(
                    u => u.Email == registerDto.Email || u.PhoneNumber == registerDto.PhoneNumber,
                    cancellationToken);

                if (existingUser != null)
                {
                    _logger.LogWarning("Registration attempt with existing email or phone: {Email}", registerDto.Email);
                    throw new AuthException("Email or phone number is already registered.", "USER_EXISTS");
                }

                // Create new user
                var newUser = new User
                {
                    Id = Guid.NewGuid(),
                    Name = registerDto.Name?.Trim() ?? string.Empty,
                    Email = registerDto.Email?.Trim().ToLower() ?? string.Empty,
                    Password = BCrypt.Net.BCrypt.HashPassword(registerDto.Password),
                    PhoneNumber = registerDto.PhoneNumber?.Trim() ?? string.Empty,
                    Role = registerDto.Role,
                    CreatedDate = DateTime.UtcNow,
                    IsActive = true
                };

                _authDb.Users.Add(newUser);
                await _authDb.SaveChangesAsync(cancellationToken);

                _logger.LogInformation("User registered successfully: {Email}, Role: {Role}", newUser.Email, newUser.Role);

                return new RegisterResponseDto
                {
                    UserId = newUser.Id,
                    Name = newUser.Name,
                    Email = newUser.Email,
                    Role = newUser.Role.ToString(),
                    Message = "Registration successful. Please verify your email."
                };
            }
            catch (AuthException)
            {
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred during user registration: {Email}", registerDto?.Email);
                throw new AuthException("An error occurred during registration. Please try again later.", "REGISTRATION_ERROR");
            }
        }

        /// <summary>
        /// Authenticates user and returns login response with JWT token
        /// </summary>
        public async Task<LoginResponseDto> LoginUserAsync(LoginDto loginDto, CancellationToken cancellationToken = default)
        {
            try
            {
                if (loginDto == null)
                    throw new AuthException("Login data cannot be null.", "INVALID_INPUT");

                if (string.IsNullOrWhiteSpace(loginDto.Email) || string.IsNullOrWhiteSpace(loginDto.Password))
                    throw new AuthException("Email and password are required.", "MISSING_CREDENTIALS");

                var user = await _authDb.Users.FirstOrDefaultAsync(
                    u => u.Email == loginDto.Email.Trim().ToLower(),
                    cancellationToken);

                if (user == null)
                {
                    _logger.LogWarning("Failed login attempt - user not found for email: {Email}", loginDto.Email);
                    throw new AuthException("Invalid email or password.", "INVALID_CREDENTIALS");
                }

                //if (!BCrypt.Net.BCrypt.Verify(loginDto.Password, user.Password))
                //{
                //    _logger.LogWarning("Failed login attempt - invalid password for email: {Email}", loginDto.Email);
                //    throw new AuthException("Invalid email or password.", "INVALID_CREDENTIALS");
                //}


                if (loginDto.Password != user.Password)
                {
                    _logger.LogWarning("Failed login attempt - invalid password for email: {Email}", loginDto.Email);
                    throw new AuthException("Invalid email or password.", "INVALID_CREDENTIALS");
                }

                //if (!user.IsActive)
                //{
                //    _logger.LogWarning("Login attempt for inactive user: {Email}", user.Email);
                //    throw new AuthException("Your account has been deactivated.", "ACCOUNT_INACTIVE");
                //}

                // Generate JWT token
                var token = _jwtTokenService.GenerateToken(user.Id.ToString(), user.Email, user.Role.ToString());
                var expiresAt = _jwtTokenService.GetTokenExpirationTime();

                _logger.LogInformation("User logged in successfully: {Email}", user.Email);

                return new LoginResponseDto
                {
                    UserId = user.Id,
                    Token = token,
                    Name = user.Name,
                    Email = user.Email,
                    Role = user.Role.ToString(),
                    ExpiresAt = expiresAt
                };
            }
            catch (AuthException)
            {
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during login for email: {Email}", loginDto?.Email);
                throw new AuthException("An unexpected error occurred during login.", "LOGIN_ERROR");
            }
        }

        /// <summary>
        /// Refreshes authentication token
        /// </summary>
        public async Task<LoginResponseDto> RefreshTokenAsync(string refreshToken, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException("Token refresh functionality not yet implemented.");
        }

        /// <summary>
        /// Checks if email is already registered
        /// </summary>
        public async Task<bool> IsEmailRegisteredAsync(string email, CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrWhiteSpace(email))
                throw new AuthException("Email cannot be empty.", "INVALID_EMAIL");

            return await _authDb.Users.AnyAsync(u => u.Email == email.Trim().ToLower(), cancellationToken);
        }
    }
}
