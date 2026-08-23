namespace Taboor_Domain.Repositories.IRepository
{
    using Taboor_Domain.Entities;

    /// <summary>
    /// Repository interface for managing refresh tokens operations.
    /// </summary>
    public interface IRefreshTokenRepository
    {
        /// <summary>
        /// Saves a new refresh token for the specified user.
        /// </summary>
        /// <param name="userId">The unique identifier of the user.</param>
        /// <param name="refreshToken">The refresh token value.</param>
        /// <param name="expiry">The expiration date and time of the token.</param>
        /// <returns>A task representing the asynchronous operation.</returns>
        Task SaveRefreshTokenAsync(string userId, string refreshToken, DateTime expiry);

        /// <summary>
        /// Retrieves the stored refresh token record for the user, regardless of its state.
        /// </summary>
        /// <param name="userId">The unique identifier of the user.</param>
        /// <param name="refreshToken">The raw refresh token value to look up.</param>
        /// <returns>The matching token record, or null when not found.</returns>
        Task<RefreshToken?> GetRefreshTokenAsync(string userId, string refreshToken);

        /// <summary>
        /// Marks a token record as used so it cannot be reused (single-use rotation).
        /// </summary>
        /// <param name="token">The token record to mark as used.</param>
        /// <returns>A task representing the asynchronous operation.</returns>
        Task MarkTokenUsedAsync(RefreshToken token);

        /// <summary>
        /// Revokes a specific refresh token for the specified user.
        /// </summary>
        /// <param name="userId">The unique identifier of the user.</param>
        /// <param name="refreshToken">The refresh token to revoke.</param>
        /// <returns>A task representing the asynchronous operation.</returns>
        Task RevokeRefreshTokenAsync(string userId, string refreshToken);

        /// <summary>
        /// Revokes all refresh tokens for the specified user.
        /// </summary>
        /// <param name="userId">The unique identifier of the user.</param>
        /// <returns>A task representing the asynchronous operation.</returns>
        Task RevokeAllRefreshTokensAsync(string userId);
    }
}