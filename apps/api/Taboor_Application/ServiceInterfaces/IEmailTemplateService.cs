namespace Taboor_Application.ServiceInterfaces
{
    /// <summary>
    /// Service interface for generating email templates.
    /// </summary>
    public interface IEmailTemplateService
    {
        /// <summary>
        /// Generates the email verification (OTP) HTML template.
        /// </summary>
        /// <param name="code">The OTP code.</param>
        /// <param name="language">The preferred language ("ar" or "en").</param>
        /// <returns>HTML content of the verification email.</returns>
        string GenerateVerificationEmail(string code, string language);

        /// <summary>
        /// Generates the password reset (OTP) HTML template.
        /// </summary>
        /// <param name="code">The reset code.</param>
        /// <param name="language">The preferred language ("ar" or "en").</param>
        /// <returns>HTML content of the password reset email.</returns>
        string GeneratePasswordResetEmail(string code, string language);

        /// <summary>
        /// Generates the password changed confirmation HTML template.
        /// </summary>
        /// <param name="language">The preferred language ("ar" or "en").</param>
        /// <returns>HTML content of the confirmation email.</returns>
        string GeneratePasswordResetConfirmationEmail(string language);
    }
}