using AutoMapper;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using System.Security.Claims;
using Taboor_Application.DTOs.Auth;
using Taboor_Application.DTOs.Token;
using Taboor_Application.ServiceInterfaces;
using Taboor_Domain.Entities;
using Taboor_Domain.Repositories;
using Taboor_Domain.Repositories.IRepository;

namespace Taboor_Application.Services
{
  /// <summary>
  /// Service for handling authentication operations including login, token refresh, and token revocation.
  /// </summary>
  public class AuthService : IAuthService
  {
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly ITokenService _tokenService;
    private readonly IMapper _mapper;
    private readonly IUnitOfWork _uow;
    private readonly ILogger<AuthService> _logger;

    /// <summary>
    /// Initializes a new instance of the <see cref="AuthService"/> class.
    /// </summary>
    public AuthService(
        ITokenService tokenService,
        IMapper mapper,
        UserManager<ApplicationUser> userManager,
        IUnitOfWork uow,
        ILogger<AuthService> logger)
    {
      _tokenService = tokenService ?? throw new ArgumentNullException(nameof(tokenService));
      _mapper = mapper ?? throw new ArgumentNullException(nameof(mapper));
      _userManager = userManager ?? throw new ArgumentNullException(nameof(userManager));
      _uow = uow ?? throw new ArgumentNullException(nameof(uow));
      _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    #region Authentication Methods

    /// <summary>
    /// Authenticates a user and generates access and refresh tokens.
    /// </summary>
    /// <param name="request">The login request containing user credentials.</param>
    /// <returns>A login response containing tokens and user information.</returns>
    public async Task<LoginResponseDTO?> Login(LoginRequestDTO request)
    {
      try
      {
        if (request == null)
          throw new ArgumentNullException(nameof(request));

        _logger.LogInformation("Login attempt for email: {Email}", request.Email);

        var user = await _userManager.FindByNameAsync(request.Email);
        if (user == null)
        {
          _logger.LogWarning("Login failed: User with email {Email} not found", request.Email);
          return null;
        }

        // 1. Check if user is blocked
        if (user.IsBlocked)
        {
          _logger.LogWarning("Login failed: User {Email} is blocked", request.Email);
          return new LoginResponseDTO { IsBlocked = true, ErrorMessage = "This account has been blocked." };
        }

        // 2. Check if user is locked out
        if (await _userManager.IsLockedOutAsync(user))
        {
          var lockoutEnd = await _userManager.GetLockoutEndDateAsync(user);
          _logger.LogWarning("Login failed: User {Email} is locked out until {LockoutEnd}", request.Email, lockoutEnd);
          return new LoginResponseDTO
          {
            IsLockedOut = true,
            ErrorMessage = $"Account is locked out until {lockoutEnd?.LocalDateTime}"
          };
        }

        // 3. Check password
        var passwordCheck = await _userManager.CheckPasswordAsync(user, request.Password);
        if (!passwordCheck)
        {
          await _userManager.AccessFailedAsync(user);
          var failedCount = await _userManager.GetAccessFailedCountAsync(user);
          _logger.LogWarning("Invalid password for email: {Email}. Failed attempts: {Count}", request.Email, failedCount);

          if (await _userManager.IsLockedOutAsync(user))
          {
            _logger.LogWarning("User {Email} is now locked out after too many failed attempts", request.Email);
            return new LoginResponseDTO
            {
              IsLockedOut = true,
              ErrorMessage = "Account locked due to multiple failed attempts. Try again later."
            };
          }

          return null;
        }

        // Reset failed count on successful login
        await _userManager.ResetAccessFailedCountAsync(user);

        var roles = await _userManager.GetRolesAsync(user);
        var userDTO = _mapper.Map<UserDTO>(user);
        userDTO.Role = roles.FirstOrDefault() ?? string.Empty;

        // Generate tokens
        var accessToken = await _tokenService.GenerateAccessToken(user);
        var refreshToken = _tokenService.GenerateRefreshToken();
        var refreshTokenExpiry = DateTime.UtcNow.AddDays(7);

        // Save refresh token to database
        await _uow.Repository<IRefreshTokenRepository>().SaveRefreshTokenAsync(user.Id, refreshToken, refreshTokenExpiry);
        await _uow.SaveAsync();

        _logger.LogInformation("User {UserId} logged in successfully", user.Id);

        return new LoginResponseDTO
        {
          Token = accessToken,
          RefreshToken = refreshToken,
          RefreshTokenExpiry = refreshTokenExpiry,
          User = userDTO
        };
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, "Unexpected error during login for email: {Email}", request?.Email);
        throw;
      }
    }

    /// <summary>
    /// Refreshes an access token using a valid refresh token.
    /// </summary>
    /// <param name="request">The refresh token request containing the expired access token and refresh token.</param>
    /// <returns>A token response containing new access and refresh tokens.</returns>
    public async Task<TokenResponseDTO> RefreshToken(RefreshTokenRequestDTO request)
    {
      try
      {
        if (request == null)
          throw new ArgumentNullException(nameof(request));

        _logger.LogInformation("Refresh token request received");

        var principal = _tokenService.GetPrincipalFromExpiredToken(request.AccessToken);
        var userId = principal.FindFirstValue(ClaimTypes.NameIdentifier);

        if (string.IsNullOrEmpty(userId))
          throw new SecurityTokenException("Invalid token: User identifier not found");

        var storedToken = await _uow.Repository<IRefreshTokenRepository>().GetRefreshTokenAsync(userId, request.RefreshToken);
        if (storedToken == null)
        {
          _logger.LogWarning("Invalid refresh token for user {UserId}", userId);
          throw new SecurityTokenException("Invalid refresh token");
        }

        return await RotateRefreshTokenAsync(storedToken);
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, "Unexpected error during token refresh");
        throw;
      }
    }

    /// <summary>
    /// Refreshes an access token using a refresh token supplied via cookie (web clients),
    /// where no expired access token is available to derive the user.
    /// </summary>
    /// <param name="refreshToken">The refresh token value read from the HttpOnly cookie.</param>
    /// <returns>A token response containing new access and refresh tokens.</returns>
    public async Task<TokenResponseDTO> RefreshTokenByCookieAsync(string refreshToken)
    {
      try
      {
        if (string.IsNullOrEmpty(refreshToken))
          throw new ArgumentNullException(nameof(refreshToken));

        _logger.LogInformation("Refresh token request received (cookie flow)");

        var storedToken = await _uow.Repository<IRefreshTokenRepository>().GetRefreshTokenByHashAsync(refreshToken);
        if (storedToken == null)
        {
          _logger.LogWarning("Invalid refresh token in cookie");
          throw new SecurityTokenException("Invalid refresh token");
        }

        return await RotateRefreshTokenAsync(storedToken);
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, "Unexpected error during token refresh (cookie flow)");
        throw;
      }
    }

    /// <summary>
    /// Validates a stored refresh token and rotates it into a new token pair.
    /// Shared by the body-token (mobile) and cookie (web) flows.
    /// </summary>
    /// <param name="storedToken">The persisted refresh token record to validate and rotate.</param>
    /// <returns>A token response containing new access and refresh tokens.</returns>
    /// <exception cref="SecurityTokenException">Thrown when the token is reused, revoked, expired, or the user is missing.</exception>
    private async Task<TokenResponseDTO> RotateRefreshTokenAsync(RefreshToken storedToken)
    {
      var userId = storedToken.UserId;

      // Reuse detection: a token that was already used to mint a new token is
      // being presented again -> genuine replay/theft, revoke the whole family.
      if (storedToken.IsUsed)
      {
        _logger.LogWarning("Refresh token reuse detected for user {UserId}; revoking all tokens", userId);
        await _uow.Repository<IRefreshTokenRepository>().RevokeAllRefreshTokensAsync(userId);
        await _uow.SaveAsync();
        throw new SecurityTokenException("Refresh token reuse detected");
      }

      // Revoked (e.g. logout or password reset) but never used -> simply reject.
      if (storedToken.IsRevoked)
      {
        _logger.LogWarning("Refresh token revoked for user {UserId}", userId);
        throw new SecurityTokenException("Refresh token revoked");
      }

      if (storedToken.Expiry <= DateTime.UtcNow)
      {
        _logger.LogWarning("Refresh token expired for user {UserId}", userId);
        throw new SecurityTokenException("Refresh token expired");
      }

      var user = await _userManager.FindByIdAsync(userId);
      if (user == null)
      {
        _logger.LogWarning("User not found during token refresh: {UserId}", userId);
        throw new SecurityTokenException("User not found");
      }

      // Revoke the presented token so it can never be used again (single-use rotation).
      await _uow.Repository<IRefreshTokenRepository>().MarkTokenUsedAsync(storedToken);

      // Generate new tokens
      var newAccessToken = await _tokenService.GenerateAccessToken(user);
      var newRefreshToken = _tokenService.GenerateRefreshToken();
      var newRefreshTokenExpiry = DateTime.UtcNow.AddDays(7);

      // Save the new refresh token in database (same transaction as the mark-used above)
      await _uow.Repository<IRefreshTokenRepository>().SaveRefreshTokenAsync(userId, newRefreshToken, newRefreshTokenExpiry);
      await _uow.SaveAsync();

      _logger.LogInformation("Tokens refreshed successfully for user {UserId}", userId);

      return new TokenResponseDTO
      {
        AccessToken = newAccessToken,
        RefreshToken = newRefreshToken,
        RefreshTokenExpiry = newRefreshTokenExpiry
      };
    }

    /// <summary>
    /// Revokes a specific refresh token for a user.
    /// </summary>
    /// <param name="userId">The unique identifier of the user.</param>
    /// <param name="refreshToken">The refresh token to revoke.</param>
    /// <returns>A task representing the asynchronous operation.</returns>
    public async Task RevokeRefreshToken(string userId, string refreshToken)
    {
      try
      {
        if (string.IsNullOrEmpty(userId))
          throw new ArgumentException("User ID cannot be null or empty.", nameof(userId));

        if (string.IsNullOrEmpty(refreshToken))
          throw new ArgumentException("Refresh token cannot be null or empty.", nameof(refreshToken));

        _logger.LogInformation("Revoking refresh token for user {UserId}", userId);

        await _uow.Repository<IRefreshTokenRepository>().RevokeRefreshTokenAsync(userId, refreshToken);
        await _uow.SaveAsync();

        _logger.LogInformation("Refresh token revoked successfully for user {UserId}", userId);
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, "Unexpected error while revoking refresh token for user {UserId}", userId);
        throw;
      }
    }

    /// <summary>
    /// Web logout: revokes the refresh token carried in the HttpOnly cookie by looking it
    /// up by hash alone, so no access token or user claims are required.
    /// </summary>
    /// <param name="refreshToken">The refresh token value read from the HttpOnly cookie.</param>
    public async Task LogoutWebAsync(string refreshToken)
    {
      if (string.IsNullOrEmpty(refreshToken))
        return;

      var stored = await _uow.Repository<IRefreshTokenRepository>().GetRefreshTokenByHashAsync(refreshToken);
      if (stored == null)
      {
        _logger.LogWarning("No stored refresh token found during web logout");
        return;
      }

      await _uow.Repository<IRefreshTokenRepository>().RevokeRefreshTokenAsync(stored.UserId, refreshToken);
      await _uow.SaveAsync();

      _logger.LogInformation("Refresh token revoked during web logout for user {UserId}", stored.UserId);
    }

    #endregion
  }
}