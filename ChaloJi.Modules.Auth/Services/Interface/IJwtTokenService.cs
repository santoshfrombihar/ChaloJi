using ChaloJi.Modules.Auth.Models.DTO;

namespace ChaloJi.Modules.Auth.Services.Interface
{
    /// <summary>
    /// Interface for JWT token operations
    /// </summary>
    public interface IJwtTokenService
    {
        /// <summary>
        /// Generates a JWT token for the authenticated user
        /// </summary>
        /// <param name="userId">User ID</param>
        /// <param name="email">User email</param>
        /// <param name="role">User role</param>
        /// <returns>JWT token string</returns>
        string GenerateToken(string userId, string email, string role);

        /// <summary>
        /// Validates a JWT token
        /// </summary>
        /// <param name="token">Token to validate</param>
        /// <returns>True if token is valid, false otherwise</returns>
        bool ValidateToken(string token);

        /// <summary>
        /// Gets token expiration time
        /// </summary>
        /// <returns>DateTime when token expires</returns>
        DateTime GetTokenExpirationTime();
    }
}