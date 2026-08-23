using Taboor_Application.ServiceInterfaces;
using Taboor_Domain.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

namespace Taboor_Application.Services
{
    /// <summary>
    /// Service for handling JWT token generation and validation operations.
    /// </summary>
    public class TokenService : ITokenService
    {
        private readonly IConfiguration _config;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly RoleManager<ApplicationRole> _roleManager;
        private readonly ILogger<TokenService> _logger;

        /// <summary>
        /// Initializes a new instance of the <see cref="TokenService"/> class.
        /// </summary>
        public TokenService(
            IConfiguration config,
            UserManager<ApplicationUser> userManager,
            RoleManager<ApplicationRole> roleManager,
            ILogger<TokenService> logger)
        {
            _config = config ?? throw new ArgumentNullException(nameof(config));
            _userManager = userManager ?? throw new ArgumentNullException(nameof(userManager));
            _roleManager = roleManager ?? throw new ArgumentNullException(nameof(roleManager));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        #region Token Generation Methods

        /// <summary>
        /// Generates an access token for the specified user.
        /// </summary>
        /// <param name="user">The application user for whom to generate the token.</param>
        /// <returns>A JWT access token string.</returns>
        public async Task<string> GenerateAccessToken(ApplicationUser user)
        {
            try
            {
                if (user == null)
                    throw new ArgumentNullException(nameof(user));

                var jwtKey = _config["JWT:Key"];
                var jwtAudience = _config["JWT:Audience"];
                var jwtIssuer = _config["JWT:Issuer"];

                if (string.IsNullOrEmpty(jwtKey))
                    throw new ArgumentException("JWT Key is not configured properly.");
                if (string.IsNullOrEmpty(jwtAudience))
                    throw new ArgumentException("JWT Audience is not configured properly.");
                if (string.IsNullOrEmpty(jwtIssuer))
                    throw new ArgumentException("JWT Issuer is not configured properly.");

                var tokenHandler = new JwtSecurityTokenHandler();
                var key = Encoding.ASCII.GetBytes(jwtKey);

                var claims = new List<Claim>
                {
                    new Claim(JwtRegisteredClaimNames.Sub, user.Id),
                    new Claim(JwtRegisteredClaimNames.Email, user.Email ?? string.Empty),
                    new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
                };

                // Add user roles to claims
                var roles = await _userManager.GetRolesAsync(user);
                claims.AddRange(roles.Select(role => new Claim(ClaimTypes.Role, role)));

                // Add user specific claims
                var userClaims = await _userManager.GetClaimsAsync(user);
                claims.AddRange(userClaims);

                // Add role claims
                foreach (var roleName in roles)
                {
                    var role = await _roleManager.FindByNameAsync(roleName);
                    if (role != null)
                    {
                        var roleClaims = await _roleManager.GetClaimsAsync(role);
                        claims.AddRange(roleClaims);
                    }
                }

                var accessTokenExpiryMinutes = _config.GetValue<int?>("JWT:AccessTokenExpiryMinutes")
                    ?? (_config.GetValue<int?>("JWT:AccessTokenExpiryDays") * 1440)
                    ?? 15;

                var tokenDescriptor = new SecurityTokenDescriptor
                {
                    Subject = new ClaimsIdentity(claims),
                    Expires = DateTime.UtcNow.AddMinutes(accessTokenExpiryMinutes),
                    NotBefore = DateTime.UtcNow,
                    IssuedAt = DateTime.UtcNow,
                    Issuer = jwtIssuer,
                    Audience = jwtAudience,
                    SigningCredentials = new SigningCredentials(
                        new SymmetricSecurityKey(key),
                        SecurityAlgorithms.HmacSha256Signature)
                };

                var token = tokenHandler.CreateToken(tokenDescriptor);
                return tokenHandler.WriteToken(token);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error occurred while generating access token for user {UserId}", user?.Id);
                throw;
            }
        }

        /// <summary>
        /// Generates a cryptographically secure refresh token.
        /// </summary>
        /// <returns>A base64 encoded refresh token string.</returns>
        public string GenerateRefreshToken()
        {
            var randomNumber = new byte[32];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomNumber);
            return Convert.ToBase64String(randomNumber);
        }

        #endregion

        #region Token Validation Methods

        /// <summary>
        /// Extracts the principal from an expired access token for refresh token validation.
        /// </summary>
        /// <param name="token">The expired JWT token.</param>
        /// <returns>The claims principal extracted from the token.</returns>
        public ClaimsPrincipal GetPrincipalFromExpiredToken(string token)
        {
            if (string.IsNullOrEmpty(token))
                throw new ArgumentException("Token cannot be null or empty.", nameof(token));

            var jwtKey = _config["JWT:Key"];
            if (string.IsNullOrEmpty(jwtKey))
                throw new ArgumentException("JWT Key is not configured properly.");

            var tokenValidationParameters = new TokenValidationParameters
            {
                ValidateAudience = false,
                ValidateIssuer = false,
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.ASCII.GetBytes(jwtKey)),
                ValidateLifetime = false
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var principal = tokenHandler.ValidateToken(token, tokenValidationParameters, out var securityToken);

            if (securityToken is not JwtSecurityToken jwtSecurityToken)
            {
                throw new SecurityTokenException("Invalid token");
            }

            var headerAlg = jwtSecurityToken.Header.Alg;
            var isValidAlg = headerAlg.Equals(SecurityAlgorithms.HmacSha256, StringComparison.InvariantCultureIgnoreCase)
                          || headerAlg.Equals("HS256", StringComparison.InvariantCultureIgnoreCase);

            if (!isValidAlg)
            {
                throw new SecurityTokenException("Invalid token");
            }

            return principal;
        }

        #endregion
    }
}