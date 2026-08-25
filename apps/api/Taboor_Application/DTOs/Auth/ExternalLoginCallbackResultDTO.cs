namespace Taboor_Application.DTOs.Auth
{
    public class ExternalLoginCallbackResultDTO
    {
        public bool IsNewUser { get; set; }
        public string? Email { get; set; }
        public string? ReturnUrl { get; set; }
        public string? Message { get; set; }
        public string? Token { get; set; }
        public string? RefreshToken { get; set; }
        public DateTime RefreshTokenExpiry { get; set; }
        public bool HasPassword { get; set; }
    }
}