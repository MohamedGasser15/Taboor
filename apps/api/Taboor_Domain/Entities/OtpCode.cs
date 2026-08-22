namespace Taboor_Domain.Entities
{
    /// <summary>
    /// Represents a one-time password (OTP) code stored in the database.
    /// </summary>
    public class OtpCode
    {
        public int Id { get; set; }

        public string Email { get; set; } = string.Empty;

        public string Code { get; set; } = string.Empty;

        public OtpPurpose Purpose { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime ExpiresAt { get; set; }

        public bool IsUsed { get; set; }

        public bool IsVerified { get; set; }
    }
}