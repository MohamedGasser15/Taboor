using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations.Schema;

namespace Taboor_Domain.Entities
{
    /// <summary>
    /// Represents an application user (customer) in the system.
    /// Maps to the "customers" table schema:
    /// id (uuid), application_user_id, full_name, phone_number, email,
    /// national_id (nullable, PII encrypted), preferred_language,
    /// no_show_count (default 0), is_blocked (default false).
    /// </summary>
    public class ApplicationUser : IdentityUser
    {
        /// <summary>
        /// Gets or sets the full name of the customer
        /// </summary>
        public string FullName { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the national ID of the customer (nullable for now)
        /// </summary>
        public string? NationalId { get; set; }

        /// <summary>
        /// Gets or sets the preferred language of the customer (e.g., "ar", "en").
        /// Auto-detected from Accept-Language header on registration.
        /// </summary>
        public string? PreferredLanguage { get; set; }

        /// <summary>
        /// Gets or sets the number of times the customer did not show up (default: 0)
        /// </summary>
        public int NoShowCount { get; set; } = 0;

        /// <summary>
        /// Gets or sets a value indicating whether the customer is blocked (default: false)
        /// </summary>
        public bool IsBlocked { get; set; } = false;

        /// <summary>
        /// Gets or sets the creation date of the customer
        /// </summary>
        public DateTime CreatedAt { get; set; }

        /// <summary>
        /// Gets a value indicating whether the user is locked out
        /// </summary>
        [NotMapped]
        public bool IsLocked => LockoutEnd.HasValue && LockoutEnd.Value > DateTimeOffset.UtcNow;
    }
}