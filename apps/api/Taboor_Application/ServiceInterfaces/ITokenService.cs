using Taboor_Domain.Entities;
using System.Security.Claims;

namespace Taboor_Application.ServiceInterfaces
{
    /// <summary>
    /// Service interface for JWT token generation and validation.
    /// </summary>
    public interface ITokenService
    {
        /// <summary>
        /// Generates a JWT access token for the specified user.
        /// </summary>
        /// <param name="user">The application user.</param>
        /// <returns>A JWT access token string.</returns>
        Task<string> GenerateAccessToken(ApplicationUser user);

        /// <summary>
        /// Generates a cryptographically secure refresh token.
        /// </summary>
        /// <returns>A base64 encoded refresh token string.</returns>
        string GenerateRefreshToken();

        /// <summary>
        /// Extracts the principal from an expired access token for refresh token validation.
        /// </summary>
        /// <param name="token">The expired JWT token.</param>
        /// <returns>The claims principal extracted from the token.</returns>
        ClaimsPrincipal GetPrincipalFromExpiredToken(string token);
    }
}