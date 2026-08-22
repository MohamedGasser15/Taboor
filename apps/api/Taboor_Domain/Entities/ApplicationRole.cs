using Microsoft.AspNetCore.Identity;

namespace Taboor_Domain.Entities
{
    /// <summary>
    /// Represents an application role, extending the identity role with soft-delete support
    /// </summary>
    public class ApplicationRole : IdentityRole
    {
    }
}