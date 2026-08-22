using Taboor_Application.Common;
using Taboor_Application.DTOs.Auth;
using Taboor_Application.DTOs.Token;
using Taboor_Application.ServiceInterfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.Globalization;
using System.Security.Claims;

namespace Taboor_API.Controllers
{
    /// <summary>
    /// Controller for handling authentication operations including login, registration,
    /// OTP email verification, token refresh, and external login (Google/Facebook).
    /// </summary>
    [Route("api/[Controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly IUserService _userService;
        private readonly IExternalLoginService _externalLoginService;
        private readonly ILogger<AuthController> _logger;

        public AuthController(
            IAuthService authService,
            IUserService userService,
            IExternalLoginService externalLoginService,
            ILogger<AuthController> logger)
        {
            _authService = authService ?? throw new ArgumentNullException(nameof(authService));
            _userService = userService ?? throw new ArgumentNullException(nameof(userService));
            _externalLoginService = externalLoginService ?? throw new ArgumentNullException(nameof(externalLoginService));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        #region Authentication Endpoints

        /// <summary>
        /// Authenticates a user and returns access and refresh tokens.
        /// </summary>
        [HttpPost("Login")]
        public async Task<IActionResult> Login([FromBody] LoginRequestDTO model)
        {
            try
            {
                _logger.LogInformation("Login attempt for email: {Email}", model?.Email);

                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                    return BadRequest(ApiResponse<object>.FailResponse("Validation failed", errors));
                }

                var response = await _authService.Login(model!);
                if (response == null)
                {
                    return Unauthorized(ApiResponse<object>.FailResponse("Invalid email or password."));
                }

                if (!string.IsNullOrEmpty(response.ErrorMessage))
                {
                    return Unauthorized(ApiResponse<object>.FailResponse(response.ErrorMessage));
                }

                _logger.LogInformation("Login successful for email: {Email}", model!.Email);
                return Ok(ApiResponse<LoginResponseDTO>.SuccessResponse(response, "Login successful"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during login");
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while processing your login request."
                });
            }
        }

        /// <summary>
        /// Refreshes an access token using a valid refresh token.
        /// </summary>
        [HttpPost("refresh")]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequestDTO request)
        {
            try
            {
                _logger.LogInformation("Refresh token request received");

                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                    return BadRequest(ApiResponse<object>.FailResponse("Validation failed", errors));
                }

                var result = await _authService.RefreshToken(request);
                if (result == null)
                {
                    return Unauthorized(ApiResponse<object>.FailResponse("Invalid or expired refresh token"));
                }

                _logger.LogInformation("Token refresh successful");
                return Ok(ApiResponse<TokenResponseDTO>.SuccessResponse(result, "Token refreshed successfully"));
            }
            catch (SecurityTokenException ex)
            {
                _logger.LogWarning(ex, "Security token exception");
                return Unauthorized(ApiResponse<object>.FailResponse("Invalid token", new List<string> { ex.Message }));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during token refresh");
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while refreshing your token."
                });
            }
        }

        /// <summary>
        /// Revokes a refresh token for the authenticated user.
        /// </summary>
        [HttpPost("revoke")]
        [Authorize]
        public async Task<IActionResult> RevokeToken([FromBody] string refreshToken)
        {
            try
            {
                _logger.LogInformation("Revoke token request received");

                if (string.IsNullOrEmpty(refreshToken))
                {
                    return BadRequest(ApiResponse<object>.FailResponse("Refresh token is required"));
                }

                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(ApiResponse<object>.FailResponse("User not authenticated"));
                }

                await _authService.RevokeRefreshToken(userId, refreshToken);
                _logger.LogInformation("Refresh token revoked successfully for user {UserId}", userId);
                return Ok(ApiResponse<object>.SuccessResponse(new { message = "Token revoked successfully" }, "Token revoked"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during token revocation");
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while revoking your token."
                });
            }
        }

        #endregion

        #region Registration Endpoints

        /// <summary>
        /// Registers a new user (requires OTP email verification first).
        /// </summary>
        [HttpPost("Register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequestDTO model)
        {
            try
            {
                _logger.LogInformation("Registration attempt for email: {Email}", model?.Email);

                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                    return BadRequest(ApiResponse<object>.FailResponse("Validation failed", errors));
                }

                var preferredLanguage = CultureInfo.CurrentUICulture.Name;
                var response = await _userService.Register(model!, preferredLanguage);
                if (response == null)
                {
                    return BadRequest(ApiResponse<object>.FailResponse("Registration failed"));
                }

                _logger.LogInformation("Registration successful for email: {Email}", model!.Email);
                return StatusCode((int)response.StatusCode, response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during registration");
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while processing your registration."
                });
            }
        }

        #endregion

        #region Email Verification (OTP) Endpoints

        /// <summary>
        /// Verifies a user's email using an OTP code.
        /// </summary>
        [HttpPost("verify-email")]
        public async Task<IActionResult> VerifyEmail([FromBody] VerifyEmailDTO dto)
        {
            try
            {
                _logger.LogInformation("Email verification attempt for email: {Email}", dto?.Email);

                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                    return BadRequest(ApiResponse<object>.FailResponse("Validation failed", errors));
                }

                var response = await _userService.VerifyEmailCodeAsync(dto!.Email, dto.Code);
                return StatusCode((int)response.StatusCode, response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during email verification");
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while verifying your email."
                });
            }
        }

        /// <summary>
        /// Sends an OTP verification code to the specified email.
        /// </summary>
        [HttpPost("send-code")]
        public async Task<IActionResult> SendVerificationCodeAsync([FromBody] SendCodeDTO dto)
        {
            try
            {
                _logger.LogInformation("Send verification code request for email: {Email}", dto?.Email);

                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                    return BadRequest(ApiResponse<object>.FailResponse("Validation failed", errors));
                }

                var response = await _userService.SendVerificationCodeAsync(dto!.Email);
                if (response == null)
                {
                    return StatusCode(500, ApiResponse<object>.FailResponse("Unable to send verification code."));
                }

                return StatusCode((int)response.StatusCode, response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error sending verification code");
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while sending the verification code."
                });
            }
        }

        #endregion

        #region External Authentication Endpoints

        /// <summary>
        /// Initiates external authentication with the specified provider (Google/Facebook).
        /// </summary>
        [HttpGet("ExternalLogin")]
        public IActionResult ExternalLogin([FromQuery] string provider, [FromQuery] string? returnUrl = null)
        {
            try
            {
                _logger.LogInformation("External login initiated with provider: {Provider}", provider);

                if (string.IsNullOrEmpty(provider))
                {
                    return BadRequest(ApiResponse<object>.FailResponse("Provider is required"));
                }

                var redirectUrl = Url.Action(nameof(ExternalLoginCallback), "Auth", new { returnUrl }, Request.Scheme);
                var properties = _externalLoginService.ConfigureExternalAuthProperties(provider, redirectUrl!);
                return Challenge(properties, provider);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error initiating external login");
                return BadRequest(ApiResponse<object>.FailResponse("External login failed", new List<string> { ex.Message }));
            }
        }

        /// <summary>
        /// Handles the callback from external authentication providers.
        /// </summary>
        [HttpGet("ExternalLoginCallback")]
        public async Task<IActionResult> ExternalLoginCallback([FromQuery] string? returnUrl = null, [FromQuery] string? remoteError = null)
        {
            try
            {
                _logger.LogInformation("External login callback received");

                var result = await _externalLoginService.HandleExternalLoginCallbackAsync(remoteError, returnUrl);
                if (!string.IsNullOrEmpty(remoteError) || result == null || string.IsNullOrEmpty(result.Email))
                {
                    return Redirect($"{returnUrl}?error=external_login_failed");
                }

                var separator = returnUrl!.Contains("?") ? "&" : "?";
                var url = $"{returnUrl}{separator}email={Uri.EscapeDataString(result.Email)}&isNewUser={result.IsNewUser.ToString().ToLower()}";
                if (!string.IsNullOrEmpty(result.Token))
                {
                    url += $"&token={Uri.EscapeDataString(result.Token)}";
                }
                if (!string.IsNullOrEmpty(result.RefreshToken))
                {
                    url += $"&refreshToken={Uri.EscapeDataString(result.RefreshToken)}";
                }
                return Redirect(url);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in external login callback");
                return Redirect($"{returnUrl}?error=external_login_failed");
            }
        }

        /// <summary>
        /// Confirms and completes external user registration.
        /// </summary>
        [HttpPost("ExternalLoginConfirmation")]
        public async Task<IActionResult> ExternalLoginConfirmation([FromBody] ExternalLoginConfirmationDto model)
        {
            try
            {
                _logger.LogInformation("External login confirmation for email: {Email}", model?.Email);

                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                    return BadRequest(ApiResponse<object>.FailResponse("Validation failed", errors));
                }

                var result = await _externalLoginService.ConfirmExternalUserAsync(model!);
                if (string.IsNullOrEmpty(result.Token))
                {
                    return BadRequest(ApiResponse<object>.FailResponse(
                        "External login confirmation failed",
                        new List<string> { result.Message ?? "Unknown error" }
                    ));
                }

                return Ok(ApiResponse<object>.SuccessResponse(new
                {
                    message = "User registered via external provider",
                    token = result.Token,
                    refreshToken = result.RefreshToken
                }, "External user confirmed"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in external login confirmation");
                return BadRequest(ApiResponse<object>.FailResponse("External login confirmation error", new List<string> { ex.Message }));
            }
        }

        #endregion
    }
}