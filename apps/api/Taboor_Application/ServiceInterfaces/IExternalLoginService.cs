using Taboor_Application.DTOs.Auth;
using Microsoft.AspNetCore.Authentication;

namespace Taboor_Application.ServiceInterfaces
{
    /// <summary>
    /// Service interface for external authentication operations (Google, Facebook).
    /// </summary>
    public interface IExternalLoginService
    {
        /// <summary>
        /// Configures authentication properties for external authentication.
        /// </summary>
        /// <param name="provider">The authentication provider name.</param>
        /// <param name="redirectUrl">The redirect URL after authentication.</param>
        /// <returns>Authentication properties for the external provider.</returns>
        AuthenticationProperties ConfigureExternalAuthProperties(string provider, string redirectUrl);

        /// <summary>
        /// Handles the callback from an external authentication provider.
        /// </summary>
        /// <param name="remoteError">Error message from the external provider, if any.</param>
        /// <param name="returnUrl">The URL to return to after successful authentication.</param>
        /// <returns>An external login callback result containing authentication information.</returns>
        Task<ExternalLoginCallbackResultDTO?> HandleExternalLoginCallbackAsync(string? remoteError, string? returnUrl);

        /// <summary>
        /// Confirms and creates a new user from external authentication.
        /// </summary>
        /// <param name="model">The external login confirmation data.</param>
        /// <returns>An external login callback result.</returns>
        Task<ExternalLoginCallbackResultDTO> ConfirmExternalUserAsync(ExternalLoginConfirmationDto model);

        /// <summary>
        /// Handles Google login from a mobile app by validating the Google ID token.
        /// </summary>
        /// <param name="idToken">The Google ID token issued to the mobile client.</param>
        /// <returns>An external login callback result containing authentication information.</returns>
        Task<ExternalLoginCallbackResultDTO> HandleGoogleMobileLoginAsync(string idToken);

        /// <summary>
        /// Handles Facebook login from a mobile app by validating the Facebook access token.
        /// </summary>
        /// <param name="accessToken">The Facebook access token issued to the mobile client.</param>
        /// <returns>An external login callback result containing authentication information.</returns>
        Task<ExternalLoginCallbackResultDTO> HandleFacebookMobileLoginAsync(string accessToken);
    }
}