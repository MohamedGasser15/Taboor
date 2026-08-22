using Taboor_Application.Common;
using Taboor_Application.DTOs.Auth;

namespace Taboor_Application.ServiceInterfaces
{
    /// <summary>
    /// Service interface for user operations: registration, email OTP verification,
    /// and password reset (forgot password).
    /// </summary>
    public interface IUserService
    {
        /// <summary>
        /// Sends a verification (OTP) code to the user email.
        /// </summary>
        /// <param name="email">The user email.</param>
        /// <returns>An API response indicating the result.</returns>
        Task<ApiResponse<object>> SendVerificationCodeAsync(string email);

        /// <summary>
        /// Verifies the email confirmation (OTP) code.
        /// </summary>
        /// <param name="email">The user email.</param>
        /// <param name="code">The OTP code.</param>
        /// <returns>An API response indicating the result.</returns>
        Task<ApiResponse<object>> VerifyEmailCodeAsync(string email, string code);

        /// <summary>
        /// Registers a new user after email confirmation.
        /// </summary>
        /// <param name="request">The registration data (email, full name, phone number, password).</param>
        /// <param name="preferredLanguage">The preferred language of the user.</param>
        /// <returns>An API response containing the created user.</returns>
        Task<ApiResponse<object>> Register(RegisterRequestDTO request, string? preferredLanguage = null);

        /// <summary>
        /// Initiates the forgot password process by sending a reset code to the user email.
        /// </summary>
        /// <param name="email">The user email.</param>
        /// <returns>An API response indicating the result.</returns>
        Task<ApiResponse<object>> ForgotPasswordAsync(string email);

        /// <summary>
        /// Verifies the password reset code.
        /// </summary>
        /// <param name="email">The user email.</param>
        /// <param name="code">The reset code.</param>
        /// <returns>An API response indicating the result.</returns>
        Task<ApiResponse<object>> VerifyResetCodeAsync(string email, string code);

        /// <summary>
        /// Resets the user's password using a verified reset code.
        /// </summary>
        /// <param name="dto">The reset password data.</param>
        /// <returns>An API response indicating the result.</returns>
        Task<ApiResponse<object>> ResetPasswordAsync(ResetPasswordDTO dto);
    }
}