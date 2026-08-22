using System.ComponentModel.DataAnnotations;

namespace Taboor_Application.DTOs.Auth
{
    public class VerifyEmailDTO
    {
        [Required(ErrorMessage = "Email is required")]
        [EmailAddress(ErrorMessage = "Invalid email address")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Code is required")]
        public string Code { get; set; } = string.Empty;
    }
}