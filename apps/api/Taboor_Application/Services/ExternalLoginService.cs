using Google.Apis.Auth;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Protocols;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Microsoft.IdentityModel.Tokens;
using System.Globalization;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Taboor_Application.Common.Constants;
using Taboor_Application.DTOs.Auth;
using Taboor_Application.ServiceInterfaces;
using Taboor_Domain.Entities;
using Taboor_Domain.Repositories;
using Taboor_Domain.Repositories.IRepository;

namespace Taboor_Application.Services
{
  /// <summary>
  /// Service for handling external authentication operations (Google, Facebook).
  /// </summary>
  public class ExternalLoginService : IExternalLoginService
  {
    private static readonly ConfigurationManager<OpenIdConnectConfiguration> _facebookConfigManager =
        new ConfigurationManager<OpenIdConnectConfiguration>(
            "https://www.facebook.com/.well-known/openid-configuration/",
            new OpenIdConnectConfigurationRetriever());

    private readonly UserManager<ApplicationUser> _userManager;
    private readonly SignInManager<ApplicationUser> _signInManager;
    private readonly RoleManager<ApplicationRole> _roleManager;
    private readonly ILogger<ExternalLoginService> _logger;
    private readonly ITokenService _tokenService;
    private readonly IUnitOfWork _uow;
    private readonly IConfiguration _configuration;

    /// <summary>
    /// Initializes a new instance of the <see cref="ExternalLoginService"/> class.
    /// </summary>
    public ExternalLoginService(
        UserManager<ApplicationUser> userManager,
        SignInManager<ApplicationUser> signInManager,
        RoleManager<ApplicationRole> roleManager,
        ILogger<ExternalLoginService> logger,
        ITokenService tokenService,
        IUnitOfWork uow,
        IConfiguration configuration)
    {
      _userManager = userManager ?? throw new ArgumentNullException(nameof(userManager));
      _signInManager = signInManager ?? throw new ArgumentNullException(nameof(signInManager));
      _roleManager = roleManager ?? throw new ArgumentNullException(nameof(roleManager));
      _logger = logger ?? throw new ArgumentNullException(nameof(logger));
      _tokenService = tokenService ?? throw new ArgumentNullException(nameof(tokenService));
      _uow = uow ?? throw new ArgumentNullException(nameof(uow));
      _configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
    }

    #region External Authentication Methods

    /// <summary>
    /// Handles the callback from an external authentication provider.
    /// </summary>
    /// <param name="remoteError">Error message from the external provider, if any.</param>
    /// <param name="returnUrl">The URL to return to after successful authentication.</param>
    /// <returns>An external login callback result containing authentication information.</returns>
    public async Task<ExternalLoginCallbackResultDTO?> HandleExternalLoginCallbackAsync(string? remoteError, string? returnUrl)
    {
      try
      {
        if (remoteError != null)
        {
          _logger.LogWarning("External login error from provider: {RemoteError}", remoteError);
          return new ExternalLoginCallbackResultDTO { Message = $"Error from provider: {remoteError}" };
        }

        var info = await _signInManager.GetExternalLoginInfoAsync();
        if (info == null)
        {
          _logger.LogWarning("Unable to retrieve external login information");
          return new ExternalLoginCallbackResultDTO { Message = "Unable to retrieve external login info." };
        }

        var user = await _userManager.FindByLoginAsync(info.LoginProvider, info.ProviderKey);
        if (user != null)
        {
          var result = await _signInManager.ExternalLoginSignInAsync(info.LoginProvider, info.ProviderKey, false);
          if (result.Succeeded)
          {
            await _signInManager.UpdateExternalAuthenticationTokensAsync(info);

            _logger.LogInformation("User {UserId} logged in successfully via {Provider}", user.Id, info.LoginProvider);

            return await BuildAuthResultAsync(user, false, returnUrl);
          }

          _logger.LogWarning("External login sign-in failed for user {UserId}", user.Id);
          return new ExternalLoginCallbackResultDTO { Message = "External login sign-in failed" };
        }

        var email = info.Principal.FindFirstValue(ClaimTypes.Email);
        var name = info.Principal.FindFirstValue(ClaimTypes.Name) ??
                   info.Principal.FindFirstValue(ClaimTypes.GivenName) ??
                   email;

        if (string.IsNullOrEmpty(email))
        {
          return new ExternalLoginCallbackResultDTO { Message = "Email not provided by external provider." };
        }

        _logger.LogInformation("External user detected with email: {Email}", email);

        var existingUser = await _userManager.FindByEmailAsync(email);
        if (existingUser != null)
        {
          _logger.LogInformation("Email {Email} already exists. Linking external login.", email);
          await _userManager.AddLoginAsync(existingUser, info);
          return await BuildAuthResultAsync(existingUser, false, returnUrl);
        }

        _logger.LogInformation("Creating new user automatically for email: {Email}", email);
        var newUser = new ApplicationUser
        {
          FullName = name ?? string.Empty,
          Email = email,
          UserName = email,
          EmailConfirmed = true,
          PreferredLanguage = CultureInfo.CurrentUICulture.Name,
          CreatedAt = DateTime.UtcNow
        };

        var createResult = await _userManager.CreateAsync(newUser);
        if (createResult.Succeeded)
        {
          if (!await _roleManager.RoleExistsAsync(SD.User))
          {
            await _roleManager.CreateAsync(new ApplicationRole { Name = SD.User });
          }
          await _userManager.AddToRoleAsync(newUser, SD.User);
          await _userManager.AddLoginAsync(newUser, info);

          return await BuildAuthResultAsync(newUser, true, returnUrl);
        }

        _logger.LogError("Failed to create user {Email}: {Errors}", email, string.Join(", ", createResult.Errors.Select(e => e.Description)));
        return new ExternalLoginCallbackResultDTO { Message = "Failed to create account" };
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, "Unexpected error during external login callback handling");
        return new ExternalLoginCallbackResultDTO { Message = "An unexpected error occurred during external login." };
      }
    }

    /// <summary>
    /// Confirms and creates a new user from external authentication.
    /// </summary>
    /// <param name="model">The external login confirmation data.</param>
    /// <returns>An external login callback result.</returns>
    public async Task<ExternalLoginCallbackResultDTO> ConfirmExternalUserAsync(ExternalLoginConfirmationDto model)
    {
      try
      {
        if (model == null)
          throw new ArgumentNullException(nameof(model));

        _logger.LogInformation("Confirming external user registration for email: {Email}", model.Email);

        var info = await _signInManager.GetExternalLoginInfoAsync();
        if (info == null)
        {
          throw new InvalidOperationException("Invalid external login info.");
        }

        var existingUser = await _userManager.FindByEmailAsync(model.Email);
        if (existingUser != null)
        {
          throw new InvalidOperationException("Email is already registered.");
        }

        var user = new ApplicationUser
        {
          FullName = model.Name,
          Email = model.Email,
          UserName = model.Email,
          CreatedAt = DateTime.UtcNow,
          EmailConfirmed = true,
          PreferredLanguage = CultureInfo.CurrentUICulture.Name
        };

        var result = await _userManager.CreateAsync(user);
        if (!result.Succeeded)
        {
          _logger.LogError("User creation failed for email {Email}: {Errors}", model.Email, string.Join(", ", result.Errors.Select(e => e.Description)));
          return new ExternalLoginCallbackResultDTO { Message = "User creation failed" };
        }

        if (!await _roleManager.RoleExistsAsync(SD.User))
        {
          await _roleManager.CreateAsync(new ApplicationRole { Name = SD.User });
        }
        await _userManager.AddToRoleAsync(user, SD.User);

        var loginResult = await _userManager.AddLoginAsync(user, info);
        if (!loginResult.Succeeded)
        {
          _logger.LogError("Adding external login failed for user {UserId}: {Errors}", user.Id, string.Join(", ", loginResult.Errors.Select(e => e.Description)));
          return new ExternalLoginCallbackResultDTO { Message = "Adding external login failed" };
        }

        await _userManager.UpdateAsync(user);

        _logger.LogInformation("External user confirmed and created successfully for email: {Email}", model.Email);

        return await BuildAuthResultAsync(user, true, null);
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, "Unexpected error during external user confirmation for email: {Email}", model?.Email);
        throw;
      }
    }

    /// <summary>
    /// Configures authentication properties for external authentication.
    /// </summary>
    /// <param name="provider">The authentication provider name.</param>
    /// <param name="redirectUrl">The redirect URL after authentication.</param>
    /// <returns>Authentication properties for the external provider.</returns>
    public AuthenticationProperties ConfigureExternalAuthProperties(string provider, string redirectUrl)
    {
      if (string.IsNullOrEmpty(provider))
        throw new ArgumentException("Provider cannot be null or empty.", nameof(provider));

      if (string.IsNullOrEmpty(redirectUrl))
        throw new ArgumentException("Redirect URL cannot be null or empty.", nameof(redirectUrl));

      return _signInManager.ConfigureExternalAuthenticationProperties(provider, redirectUrl);
    }

    #endregion

    #region Mobile External Login Methods

    /// <summary>
    /// Handles Google login from a mobile app by validating the Google ID token.
    /// </summary>
    /// <param name="idToken">The Google ID token issued to the mobile client.</param>
    /// <returns>An external login callback result containing authentication information.</returns>
    public async Task<ExternalLoginCallbackResultDTO> HandleGoogleMobileLoginAsync(string idToken)
    {
      if (string.IsNullOrEmpty(idToken))
        return new ExternalLoginCallbackResultDTO { Message = "idToken is required." };

      try
      {
        var googleClientId = _configuration["Authentication:Google:ClientId"];
        var settings = new GoogleJsonWebSignature.ValidationSettings();

        if (!string.IsNullOrEmpty(googleClientId) && googleClientId != "YOUR_GOOGLE_CLIENT_ID")
          settings.Audience = new[] { googleClientId };

        var payload = await GoogleJsonWebSignature.ValidateAsync(idToken, settings);

        var email = payload.Email;
        var name = payload.Name ?? email;
        var providerKey = payload.Subject;

        _logger.LogInformation("Google mobile login attempt for email: {Email}", email);

        var user = await _userManager.FindByLoginAsync("Google", providerKey);
        if (user != null)
        {
          return await BuildAuthResultAsync(user, false, null);
        }

        if (!string.IsNullOrEmpty(email))
        {
          var existingUser = await _userManager.FindByEmailAsync(email);
          if (existingUser != null)
          {
            _logger.LogInformation("Email {Email} already exists. Linking Google login.", email);
            await _userManager.AddLoginAsync(existingUser, new UserLoginInfo("Google", providerKey, "Google"));
            return await BuildAuthResultAsync(existingUser, false, null);
          }
        }

        var newUser = new ApplicationUser
        {
          FullName = name ?? string.Empty,
          Email = email,
          UserName = email,
          EmailConfirmed = !string.IsNullOrEmpty(email),
          PreferredLanguage = CultureInfo.CurrentUICulture.Name,
          CreatedAt = DateTime.UtcNow
        };

        var createResult = await _userManager.CreateAsync(newUser);
        if (!createResult.Succeeded)
        {
          _logger.LogError("Google user creation failed for email {Email}: {Errors}", email, string.Join(", ", createResult.Errors.Select(e => e.Description)));
          return new ExternalLoginCallbackResultDTO { Message = "User creation failed" };
        }

        if (!await _roleManager.RoleExistsAsync(SD.User))
        {
          await _roleManager.CreateAsync(new ApplicationRole { Name = SD.User });
        }
        await _userManager.AddToRoleAsync(newUser, SD.User);
        await _userManager.AddLoginAsync(newUser, new UserLoginInfo("Google", providerKey, "Google"));

        return await BuildAuthResultAsync(newUser, true, null);
      }
      catch (InvalidJwtException ex)
      {
        _logger.LogError(ex, "Invalid Google idToken: {Message}", ex.Message);
        return new ExternalLoginCallbackResultDTO { Message = "Invalid Google token." };
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, "Unexpected error during Google mobile login");
        return new ExternalLoginCallbackResultDTO { Message = "Google login failed." };
      }
    }

    /// <summary>
    /// Handles Facebook login from a mobile app by validating the Facebook access token.
    /// </summary>
    /// <param name="accessToken">The Facebook access token issued to the mobile client.</param>
    /// <returns>An external login callback result containing authentication information.</returns>
    public async Task<ExternalLoginCallbackResultDTO> HandleFacebookMobileLoginAsync(string accessToken)
    {
      if (string.IsNullOrEmpty(accessToken))
        return new ExternalLoginCallbackResultDTO { Message = "Access token is required." };

      try
      {
        var appId = _configuration["Authentication:Facebook:AppId"];

        var discoveryDocument = await _facebookConfigManager.GetConfigurationAsync();
        var tokenHandler = new JwtSecurityTokenHandler();

        var validationParameters = new TokenValidationParameters
        {
          ValidateIssuer = true,
          ValidIssuer = "https://www.facebook.com",
          ValidateAudience = true,
          ValidAudience = appId,
          ValidateLifetime = true,
          IssuerSigningKeys = discoveryDocument.SigningKeys,
          NameClaimType = "name",
          RoleClaimType = "role"
        };

        var principal = tokenHandler.ValidateToken(accessToken, validationParameters, out var validatedToken);

        var fbId = principal.FindFirst(ClaimTypes.NameIdentifier)?.Value
                   ?? principal.FindFirst("sub")?.Value;
        var fbEmail = principal.FindFirst("email")?.Value
                      ?? principal.FindFirst(ClaimTypes.Email)?.Value;
        var fbName = principal.FindFirst("name")?.Value
                     ?? principal.FindFirst(ClaimTypes.Name)?.Value;

        if (string.IsNullOrEmpty(fbId))
          return new ExternalLoginCallbackResultDTO { Message = "Failed to retrieve Facebook user info." };

        var email = fbEmail;
        var name = fbName ?? email;
        var providerKey = fbId;

        _logger.LogInformation("Facebook mobile login attempt for email: {Email}", email);

        var user = await _userManager.FindByLoginAsync("Facebook", providerKey);
        if (user != null)
        {
          return await BuildAuthResultAsync(user, false, null);
        }

        if (!string.IsNullOrEmpty(email))
        {
          var existingUser = await _userManager.FindByEmailAsync(email);
          if (existingUser != null)
          {
            _logger.LogInformation("Email {Email} already exists. Linking Facebook login.", email);
            await _userManager.AddLoginAsync(existingUser, new UserLoginInfo("Facebook", providerKey, "Facebook"));
            return await BuildAuthResultAsync(existingUser, false, null);
          }
        }

        var newUser = new ApplicationUser
        {
          FullName = name ?? email ?? "Facebook User",
          Email = email,
          UserName = email ?? $"fb_{providerKey}",
          EmailConfirmed = email != null,
          PreferredLanguage = CultureInfo.CurrentUICulture.Name,
          CreatedAt = DateTime.UtcNow
        };

        var createResult = await _userManager.CreateAsync(newUser);
        if (!createResult.Succeeded)
        {
          var errors = string.Join("; ", createResult.Errors.Select(e => $"{e.Code}: {e.Description}"));
          _logger.LogError("Facebook user creation failed: {Errors}", errors);
          return new ExternalLoginCallbackResultDTO { Message = $"User creation failed: {errors}" };
        }

        if (!await _roleManager.RoleExistsAsync(SD.User))
        {
          await _roleManager.CreateAsync(new ApplicationRole { Name = SD.User });
        }
        await _userManager.AddToRoleAsync(newUser, SD.User);
        await _userManager.AddLoginAsync(newUser, new UserLoginInfo("Facebook", providerKey, "Facebook"));

        return await BuildAuthResultAsync(newUser, true, null);
      }
      catch (SecurityTokenException ex)
      {
        _logger.LogError(ex, "Invalid Facebook JWT token");
        return new ExternalLoginCallbackResultDTO { Message = "Invalid Facebook token." };
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, "Facebook login error");
        return new ExternalLoginCallbackResultDTO { Message = "Facebook login failed." };
      }
    }

    #endregion

    #region Private Helper Methods

    /// <summary>
    /// Builds the external login result with access + refresh tokens.
    /// </summary>
    private async Task<ExternalLoginCallbackResultDTO> BuildAuthResultAsync(
        ApplicationUser user,
        bool isNewUser,
        string? returnUrl)
    {
      var accessToken = await _tokenService.GenerateAccessToken(user);
      var refreshToken = _tokenService.GenerateRefreshToken();
      var refreshTokenExpiry = DateTime.UtcNow.AddDays(7);

      await _uow.Repository<IRefreshTokenRepository>().SaveRefreshTokenAsync(user.Id, refreshToken, refreshTokenExpiry);
      await _uow.SaveAsync();

      return new ExternalLoginCallbackResultDTO
      {
        IsNewUser = isNewUser,
        Email = user.Email,
        Message = "Logged in successfully via external provider",
        ReturnUrl = returnUrl,
        Token = accessToken,
        RefreshToken = refreshToken,
        RefreshTokenExpiry = refreshTokenExpiry,
        HasPassword = await _userManager.HasPasswordAsync(user)
      };
    }

    #endregion
  }
}