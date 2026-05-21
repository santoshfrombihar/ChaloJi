using System;
using System.Collections.Generic;
using System.Text;
using ChaloJi.Modules.Auth.Models.Enum;

namespace ChaloJi.Modules.Auth.Models.DTO
{
    public class LoginResponseDto
    {
        public string Token { get; set; }
         public string Name { get; set; }
         public string Email { get; set; }
         public UserType Role { get; set; }
    }
}
