using Taboor_Domain.Entities;
using Taboor_Infrastructure.DB;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Taboor_Domain.Repositories.IRepository;
using Taboor_Infrastructure.Security;

namespace Taboor_Infrastructure.Persistence.Repositories
{
    /// <summary>
    /// Repository implementation for managing refresh tokens in the database.
    /// </summary>
    public class RefreshTokenRepository : IRefreshTokenRepository
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<RefreshTokenRepository> _logger;

        /// <summary>
        /// Initializes a new instance of the <see cref="RefreshTokenRepository"/> class.
        /// </summary>
        /// <param name="context">The application database context.</param>
        /// <param name="logger">The logger instance.</param>
        public RefreshTokenRepository(ApplicationDbContext context, ILogger<RefreshTokenRepository> logger)
        {
            _context = context ?? throw new ArgumentNullException(nameof(context));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        #region Token Management Methods

        /// <summary>
        /// Saves a new refresh token for the specified user.
        /// </summary>
        /// <param name="userId">The unique identifier of the user.</param>
        /// <param name="refreshToken">The refresh token value.</param>
        /// <param name="expiry">The expiration date and time of the token.</param>
        /// <returns>A task representing the asynchronous operation.</returns>
        /// <exception cref="ArgumentException">Thrown when input parameters are invalid.</exception>
        /// <exception cref="DbUpdateException">Thrown when database update fails.</exception>
        public async Task SaveRefreshTokenAsync(string userId, string refreshToken, DateTime expiry)
        {
            try
            {
                // Validate input parameters
                if (string.IsNullOrEmpty(userId))
                    throw new ArgumentException("User ID cannot be null or empty.", nameof(userId));

                if (string.IsNullOrEmpty(refreshToken))
                    throw new ArgumentException("Refresh token cannot be null or empty.", nameof(refreshToken));

                if (expiry <= DateTime.UtcNow)
                    throw new ArgumentException("Expiry date must be in the future.", nameof(expiry));

                _logger.LogInformation("Saving refresh token for user {UserId}", userId);

                var token = new RefreshToken
                {
                    UserId = userId,
                    Token = RefreshTokenHasher.Hash(refreshToken),
                    Expiry = expiry,
                    CreatedAt = DateTime.UtcNow,
                    IsRevoked = false,
                    IsUsed = false
                };

                _context.RefreshTokens.Add(token);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Refresh token saved successfully for user {UserId}", userId);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning(ex, "Invalid argument while saving refresh token for user {UserId}", userId);
                throw;
            }
            catch (DbUpdateException ex)
            {
                _logger.LogError(ex, "Database update failed while saving refresh token for user {UserId}", userId);
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error occurred while saving refresh token for user {UserId}", userId);
                throw;
            }
        }

        /// <summary>
        /// Retrieves the stored refresh token record for the user, regardless of its state.
        /// </summary>
        /// <param name="userId">The unique identifier of the user.</param>
        /// <param name="refreshToken">The raw refresh token value to look up.</param>
        /// <returns>The matching token record, or null when not found.</returns>
        /// <exception cref="ArgumentException">Thrown when input parameters are invalid.</exception>
        public async Task<RefreshToken?> GetRefreshTokenAsync(string userId, string refreshToken)
        {
            try
            {
                // Validate input parameters
                if (string.IsNullOrEmpty(userId))
                    throw new ArgumentException("User ID cannot be null or empty.", nameof(userId));

                if (string.IsNullOrEmpty(refreshToken))
                    throw new ArgumentException("Refresh token cannot be null or empty.", nameof(refreshToken));

                _logger.LogInformation("Looking up refresh token for user {UserId}", userId);

                var hashedToken = RefreshTokenHasher.Hash(refreshToken);
                return await _context.RefreshTokens
                    .Where(rt => rt.UserId == userId && rt.Token == hashedToken)
                    .FirstOrDefaultAsync();
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning(ex, "Invalid argument while looking up refresh token for user {UserId}", userId);
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error occurred while looking up refresh token for user {UserId}", userId);
                throw;
            }
        }

        /// <summary>
        /// Marks a token record as used so it cannot be reused (single-use rotation).
        /// </summary>
        /// <param name="token">The token record to mark as used.</param>
        /// <returns>A task representing the asynchronous operation.</returns>
        /// <exception cref="ArgumentNullException">Thrown when the token is null.</exception>
        public async Task MarkTokenUsedAsync(RefreshToken token)
        {
            try
            {
                if (token == null)
                    throw new ArgumentNullException(nameof(token));

                token.IsUsed = true;
                _context.RefreshTokens.Update(token);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Refresh token marked as used for user {UserId}", token.UserId);
            }
            catch (ArgumentNullException ex)
            {
                _logger.LogWarning(ex, "Token was null while marking as used");
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error occurred while marking refresh token as used for user {UserId}", token?.UserId);
                throw;
            }
        }

        #endregion

        #region Token Revocation Methods

        /// <summary>
        /// Revokes a specific refresh token for the specified user.
        /// </summary>
        /// <param name="userId">The unique identifier of the user.</param>
        /// <param name="refreshToken">The refresh token to revoke.</param>
        /// <returns>A task representing the asynchronous operation.</returns>
        /// <exception cref="ArgumentException">Thrown when input parameters are invalid.</exception>
        public async Task RevokeRefreshTokenAsync(string userId, string refreshToken)
        {
            try
            {
                // Validate input parameters
                if (string.IsNullOrEmpty(userId))
                    throw new ArgumentException("User ID cannot be null or empty.", nameof(userId));

                if (string.IsNullOrEmpty(refreshToken))
                    throw new ArgumentException("Refresh token cannot be null or empty.", nameof(refreshToken));

                _logger.LogInformation("Revoking refresh token for user {UserId}", userId);

                var hashedToken = RefreshTokenHasher.Hash(refreshToken);
                var token = await _context.RefreshTokens
                    .Where(rt => rt.UserId == userId && rt.Token == hashedToken)
                    .FirstOrDefaultAsync();

                if (token != null)
                {
                    token.IsRevoked = true;
                    await _context.SaveChangesAsync();
                    _logger.LogInformation("Refresh token revoked successfully for user {UserId}", userId);
                }
                else
                {
                    _logger.LogWarning("Refresh token not found for user {UserId} during revocation", userId);
                }
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning(ex, "Invalid argument while revoking refresh token for user {UserId}", userId);
                throw;
            }
            catch (DbUpdateException ex)
            {
                _logger.LogError(ex, "Database update failed while revoking refresh token for user {UserId}", userId);
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error occurred while revoking refresh token for user {UserId}", userId);
                throw;
            }
        }

        /// <summary>
        /// Revokes all refresh tokens for the specified user.
        /// </summary>
        /// <param name="userId">The unique identifier of the user.</param>
        /// <returns>A task representing the asynchronous operation.</returns>
        /// <exception cref="ArgumentException">Thrown when user ID is invalid.</exception>
        public async Task RevokeAllRefreshTokensAsync(string userId)
        {
            try
            {
                // Validate input parameter
                if (string.IsNullOrEmpty(userId))
                    throw new ArgumentException("User ID cannot be null or empty.", nameof(userId));

                _logger.LogInformation("Revoking all refresh tokens for user {UserId}", userId);

                var tokens = await _context.RefreshTokens
                    .Where(rt => rt.UserId == userId && !rt.IsRevoked)
                    .ToListAsync();

                if (tokens.Any())
                {
                    foreach (var token in tokens)
                    {
                        token.IsRevoked = true;
                    }

                    await _context.SaveChangesAsync();
                    _logger.LogInformation("All {TokenCount} refresh tokens revoked for user {UserId}", tokens.Count, userId);
                }
                else
                {
                    _logger.LogInformation("No active refresh tokens found for user {UserId}", userId);
                }
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning(ex, "Invalid argument while revoking all refresh tokens for user {UserId}", userId);
                throw;
            }
            catch (DbUpdateException ex)
            {
                _logger.LogError(ex, "Database update failed while revoking all refresh tokens for user {UserId}", userId);
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error occurred while revoking all refresh tokens for user {UserId}", userId);
                throw;
            }
        }

        #endregion
    }
}