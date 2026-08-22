namespace Taboor_Application.DTOs.Auth
{
    public class LoginResponseDTO
    {
        public UserDTO? User { get; set; }
        public string? Token { get; set; }
        public string? RefreshToken { get; set; }
        public DateTime RefreshTokenExpiry { get; set; }
        public string? ErrorMessage { get; set; }
        public bool IsLockedOut { get; set; }
        public bool IsBlocked { get; set; }
    }
}