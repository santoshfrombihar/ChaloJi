using System;
using System.Collections.Generic;
using System.Text;
using ChaloJi.Modules.Auth.Models.Enum;

namespace ChaloJi.Modules.Auth.Models.DTO
{
    /// <summary>
    /// Response DTO for user login
    /// </summary>
    public class LoginResponseDto
    {
        public Guid UserId { get; set; }
        public string Token { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
        public DateTime ExpiresAt { get; set; }
    }
}
