using Taboor_Domain.Entities;

namespace Taboor_Domain.Repositories.IRepository
{
    /// <summary>
    /// Repository interface for managing OTP codes.
    /// </summary>
    public interface IOtpRepository
    {
        /// <summary>
        /// Retrieves the first valid (not used, not expired) OTP matching the given criteria.
        /// </summary>
        /// <param name="email">The email the code was sent to.</param>
        /// <param name="code">The OTP code.</param>
        /// <param name="purpose">The purpose of the code.</param>
        /// <returns>The matching OTP or null.</returns>
        Task<OtpCode?> GetValidAsync(string email, string code, OtpPurpose purpose);

        /// <summary>
        /// Checks whether a verified (email-confirmed) OTP exists for the email within its validity window.
        /// </summary>
        /// <param name="email">The email.</param>
        /// <param name="purpose">The purpose of the code.</param>
        /// <returns>True if a verified OTP exists.</returns>
        Task<bool> HasVerifiedAsync(string email, OtpPurpose purpose);

        /// <summary>
        /// Creates a new OTP code.
        /// </summary>
        /// <param name="otp">The OTP to create.</param>
        /// <returns>A task representing the asynchronous operation.</returns>
        Task CreateAsync(OtpCode otp);

        /// <summary>
        /// Marks all active (unused) OTPs for the email/purpose as used.
        /// </summary>
        /// <param name="email">The email.</param>
        /// <param name="purpose">The purpose of the code.</param>
        /// <returns>A task representing the asynchronous operation.</returns>
        Task InvalidateActiveAsync(string email, OtpPurpose purpose);

        /// <summary>
        /// Marks the given OTP as verified and extends its validity window (for completing the flow).
        /// </summary>
        /// <param name="otp">The OTP to update.</param>
        /// <returns>A task representing the asynchronous operation.</returns>
        Task MarkVerifiedAsync(OtpCode otp);

        /// <summary>
        /// Marks the given OTP as used.
        /// </summary>
        /// <param name="otp">The OTP to update.</param>
        /// <returns>A task representing the asynchronous operation.</returns>
        Task MarkUsedAsync(OtpCode otp);
    }
}