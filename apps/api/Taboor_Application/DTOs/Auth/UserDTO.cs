namespace Taboor_Application.DTOs.Auth
{
    public class UserDTO
    {
        public string Id { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string? NationalId { get; set; }
        public string? PreferredLanguage { get; set; }
        public int NoShowCount { get; set; }
        public bool IsBlocked { get; set; }
        public string Role { get; set; } = string.Empty;
        public bool IsLocked { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}