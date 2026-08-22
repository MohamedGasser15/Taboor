using System.ComponentModel.DataAnnotations;

namespace Taboor_Application.DTOs.Auth
{
    public class SendCodeDTO
    {
        [Required(ErrorMessage = "Email is required")]
        [EmailAddress(ErrorMessage = "Invalid email address")]
        public string Email { get; set; } = string.Empty;
    }
}