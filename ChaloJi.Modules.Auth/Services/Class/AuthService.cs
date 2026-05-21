
using ChaloJi.Modules.Auth.Data;
using ChaloJi.Modules.Auth.Models;
using ChaloJi.Modules.Auth.Models.DTO;
using ChaloJi.Modules.Auth.Models.Enum;
using ChaloJi.Modules.Auth.Services.Interface;
using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;

namespace ChaloJi.Modules.Auth.Services.Class
{
    public class AuthService : IAuthService
    {
        public readonly AuthDbContext _authDb;
        public readonly ILogger<AuthService> _logger;
        public AuthService(AuthDbContext authDb, ILogger<AuthService> logger)
        {
            _authDb = authDb;
            _logger = logger;
        }
        public async Task<LoginResponseDto> LoginUser(LoginDto loginDto)
        {
            try
            {
                var user = await _authDb.Users.FirstOrDefaultAsync(u => u.Email == loginDto.Email && u.Password == loginDto.Password);
                if (user != null)
                {
                    return new LoginResponseDto
                    {
                        Token = "not implemented",
                        Name = user.Name,
                        Email = user.Email,
                        Role = user.Role
                    };
                }
                else
                {
                    _logger.LogWarning("Invalid login attempt for email: {Email}", loginDto.Email);
                    throw new Exception("Invalid email or password.");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while logging in user with email: {Email}", loginDto.Email);
                throw new Exception(ex.Message);
            }
        }

        public async Task<RegisterDto> RegisterUser(RegisterDto registerDto)
        {
            try
            {
                var existingUser = await _authDb.Users.FirstOrDefaultAsync(u => u.Email == registerDto.Email || u.PhoneNumber == registerDto.PhoneNumber);
                if (existingUser != null)
                {
                    _logger.LogWarning("Attempt to register with an already existing email or phone number: {Email}, {PhoneNumber}", registerDto.Email, registerDto.PhoneNumber);
                    throw new Exception("Email or phone number already exists.");
                }

                var newUser = new User
                {
                    Name = registerDto.Name,
                    Email = registerDto.Email,
                    Password = registerDto.Password, 
                    PhoneNumber = registerDto.PhoneNumber,
                    Role = registerDto.Role
                };
                if (registerDto.Role == UserType.Driver)
                {
                    newUser.DriverProfile = new DriverProfile
                    {
                        VehicleNumber = registerDto.VehicleNumber,
                        VehicleType = registerDto.VehicleType,
                        IsVerified = false
                    };
                }
                _authDb.Users.Add(newUser);
                await _authDb.SaveChangesAsync();

                return registerDto;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while registering user with email: {Email}", registerDto.Email);
                throw new Exception(ex.Message);
            }
        }
    }
}
