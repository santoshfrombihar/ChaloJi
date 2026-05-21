using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace ChaloJi.Modules.Auth.Models
{
    public class DriverProfile
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        [Required]
        public Guid UserId { get; set; }
        public User User { get; set; }

        [Required]
        public string LicenseNumber { get; set; }

        [Required]
        public string VehicleNumber { get; set; }

        [Required]
        public string VehicleType { get; set; }

        public bool IsVerified { get; set; }

        public bool IsOnline { get; set; }
        
    }
}
