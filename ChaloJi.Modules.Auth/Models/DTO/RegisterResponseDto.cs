namespace ChaloJi.Modules.Auth.Models.DTO
{
    /// <summary>
    /// Response DTO for user registration
    /// </summary>
    public class RegisterResponseDto
    {
        public Guid UserId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
        public string Message { get; set; } = "Registration successful. Please verify your email.";
    }
}