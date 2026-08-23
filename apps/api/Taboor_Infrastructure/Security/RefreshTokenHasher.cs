using System.Security.Cryptography;
using System.Text;

namespace Taboor_Infrastructure.Security
{
    /// <summary>
    /// Hashes refresh tokens before they are persisted so the database never
    /// stores the raw token value. Tokens are cryptographically random, so
    /// hashing loses nothing: we only ever compare, never decrypt.
    /// </summary>
    public static class RefreshTokenHasher
    {
        /// <summary>
        /// Computes the SHA-256 hex digest of a refresh token.
        /// </summary>
        /// <param name="token">The raw refresh token.</param>
        /// <returns>The SHA-256 hash as an uppercase hex string.</returns>
        public static string Hash(string token)
        {
            ArgumentNullException.ThrowIfNull(token);

            var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(token));
            return Convert.ToHexString(bytes);
        }
    }
}