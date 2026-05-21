using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;
using ChaloJi.Modules.Auth.Models.Enum;

namespace ChaloJi.Modules.Auth.Models
{
    public class User
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        [Required]
        public string Name { get; set; }

        [Required]
        public string Email { get; set; }

        [Required]
        public string Password { get; set; }

        [Required]
        public string PhoneNumber { get; set; }

        [Required]
        public UserType Role { get; set; }

        public bool IsActive { get; set; }
        public DateTime CreatedDate { get; set; }

        public DriverProfile? DriverProfile { get; set; }
    }
}
