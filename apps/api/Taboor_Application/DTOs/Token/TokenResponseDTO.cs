namespace Taboor_Application.DTOs.Token
{
    public class TokenResponseDTO
    {
        public string AccessToken { get; set; } = string.Empty;
        public string? RefreshToken { get; set; }
        public DateTime RefreshTokenExpiry { get; set; }
    }
}