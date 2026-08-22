using System.ComponentModel.DataAnnotations;

namespace Taboor_Application.DTOs.Auth
{
    public class ExternalLoginConfirmationDto
    {
        [Required(ErrorMessage = "Name is required")]
        public string Name { get; set; } = string.Empty;

        public string Email { get; set; } = string.Empty;
    }
}