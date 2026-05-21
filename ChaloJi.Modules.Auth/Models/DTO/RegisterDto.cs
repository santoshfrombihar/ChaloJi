using System;
using System.Collections.Generic;
using System.Text;
using ChaloJi.Modules.Auth.Models.Enum;

namespace ChaloJi.Modules.Auth.Models.DTO
{
    public class RegisterDto
    {
        public string Name { get; set;  }
        public string Email { get; set; }
        public string Password { get; set; }
        public string PhoneNumber { get; set; }
        public UserType Role { get; set; }
        public string? LicenseNumber { get; set; }
        public string? VehicleNumber { get; set; }

        public string? VehicleType { get; set; }
    }
}
