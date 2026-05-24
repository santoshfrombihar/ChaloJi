using System.ComponentModel.DataAnnotations;
using ChaloJi.Modules.Auth.Models.DTO;

namespace ChaloJi.Modules.Auth.Validators
{
    /// <summary>
    /// Validator for RegisterDto
    /// </summary>
    public static class RegisterDtoValidator
    {
        public static ValidationResult? Validate(RegisterDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Name) || dto.Name.Length < 2)
                return new ValidationResult("Name must be at least 2 characters long.");

            if (string.IsNullOrWhiteSpace(dto.Email) || !IsValidEmail(dto.Email))
                return new ValidationResult("Invalid email format.");

            if (string.IsNullOrWhiteSpace(dto.Password) || dto.Password.Length < 8)
                return new ValidationResult("Password must be at least 8 characters long.");

            if (string.IsNullOrWhiteSpace(dto.PhoneNumber) || !IsValidPhoneNumber(dto.PhoneNumber))
                return new ValidationResult("Invalid phone number format.");

            return null; // Valid
        }

        private static bool IsValidEmail(string email)
        {
            try
            {
                var addr = new System.Net.Mail.MailAddress(email);
                return addr.Address == email;
            }
            catch
            {
                return false;
            }
        }

        private static bool IsValidPhoneNumber(string phoneNumber)
        {
            return System.Text.RegularExpressions.Regex.IsMatch(phoneNumber, @"^[0-9]{10}$");
        }
    }
}