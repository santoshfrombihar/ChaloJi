using ChaloJi.Modules.Auth.Models.DTO;
using System.Threading;
using System.Threading.Tasks;

namespace ChaloJi.Modules.Auth.Services.Interface
{
    /// <summary>
    /// Interface for authentication service operations
    /// </summary>
    public interface IAuthService
    {
        /// <summary>
        /// Registers a new user
        /// </summary>
        Task<RegisterResponseDto> RegisterUserAsync(RegisterDto registerDto, CancellationToken cancellationToken = default);

        /// <summary>
        /// Authenticates user and returns login response with token
        /// </summary>
        Task<LoginResponseDto> LoginUserAsync(LoginDto loginDto, CancellationToken cancellationToken = default);

        /// <summary>
        /// Refreshes authentication token
        /// </summary>
        Task<LoginResponseDto> RefreshTokenAsync(string refreshToken, CancellationToken cancellationToken = default);

        /// <summary>
        /// Validates if email is already registered
        /// </summary>
        Task<bool> IsEmailRegisteredAsync(string email, CancellationToken cancellationToken = default);
    }
}
