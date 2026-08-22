using System.ComponentModel.DataAnnotations;

namespace Taboor_Application.DTOs.Token
{
    public class RefreshTokenRequestDTO
    {
        [Required]
        public string AccessToken { get; set; } = string.Empty;

        [Required]
        public string RefreshToken { get; set; } = string.Empty;
    }
}