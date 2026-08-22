using AutoMapper;
using Taboor_Application.Common;
using Taboor_Application.Common.Constants;
using Taboor_Application.DTOs.Auth;
using Taboor_Application.ServiceInterfaces;
using Taboor_Domain.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.Globalization;
using Taboor_Domain.Interfaces.Repositories.IRepository;

namespace Taboor_Application.Services
{
    /// <summary>
    /// Service for user operations: email OTP verification (database-backed) and registration.
    /// Workflow: enter email -> send OTP -> verify OTP -> complete registration.
    /// </summary>
    public class UserService : IUserService
    {
        #region Dependencies

        private readonly UserManager<ApplicationUser> _userManager;
        private readonly RoleManager<ApplicationRole> _roleManager;
        private readonly IMapper _mapper;
        private readonly IOtpRepository _otpRepository;
        private readonly IEmailSender _emailSender;
        private readonly IEmailTemplateService _emailTemplateService;
        private readonly ILogger<UserService> _logger;

        #endregion

        #region Constructor

        /// <summary>
        /// Initializes a new instance of the UserService class
        /// </summary>
        public UserService(
            UserManager<ApplicationUser> userManager,
            RoleManager<ApplicationRole> roleManager,
            IMapper mapper,
            IOtpRepository otpRepository,
            IEmailSender emailSender,
            IEmailTemplateService emailTemplateService,
            ILogger<UserService> logger)
        {
            _userManager = userManager ?? throw new ArgumentNullException(nameof(userManager));
            _roleManager = roleManager ?? throw new ArgumentNullException(nameof(roleManager));
            _mapper = mapper ?? throw new ArgumentNullException(nameof(mapper));
            _otpRepository = otpRepository ?? throw new ArgumentNullException(nameof(otpRepository));
            _emailSender = emailSender ?? throw new ArgumentNullException(nameof(emailSender));
            _emailTemplateService = emailTemplateService ?? throw new ArgumentNullException(nameof(emailTemplateService));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        #endregion

        #region Registration & OTP Verification

        /// <summary>
        /// Sends verification (OTP) code to user email and stores it in the database
        /// </summary>
        public async Task<ApiResponse<object>> SendVerificationCodeAsync(string email)
        {
            try
            {
                if (await IsEmailExistsAsync(email))
                {
                    return ApiResponse<object>.FailResponse(
                        "This email is already registered.",
                        new List<string> { "Email already exists" }
                    );
                }

                // Invalidate any previous active codes for this email
                await _otpRepository.InvalidateActiveAsync(email, OtpPurpose.EmailVerification);

                var code = GenerateRandomCode();
                await _otpRepository.CreateAsync(new OtpCode
                {
                    Email = email,
                    Code = code,
                    Purpose = OtpPurpose.EmailVerification,
                    CreatedAt = DateTime.UtcNow,
                    ExpiresAt = DateTime.UtcNow.AddMinutes(10),
                    IsUsed = false,
                    IsVerified = false
                });

                var emailBody = _emailTemplateService.GenerateVerificationEmail(code, CultureInfo.CurrentUICulture.Name);
                await _emailSender.SendEmailAsync(email, "Taboor - Verification Code", emailBody);

                return ApiResponse<object>.SuccessResponse(null, "Verification code sent to your email.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while sending verification code to: {Email}", email);
                return ApiResponse<object>.FailResponse(
                    "An error occurred while sending the verification code.",
                    new List<string> { ex.Message }
                );
            }
        }

        /// <summary>
        /// Verifies email confirmation (OTP) code against the database
        /// </summary>
        public async Task<ApiResponse<object>> VerifyEmailCodeAsync(string email, string code)
        {
            try
            {
                var otp = await _otpRepository.GetValidAsync(email, code, OtpPurpose.EmailVerification);
                if (otp == null)
                {
                    return ApiResponse<object>.FailResponse(
                        "The verification code is invalid or has expired.",
                        new List<string> { "Code expired or invalid" }
                    );
                }

                // Mark as verified and extend the window for registration completion (30 minutes)
                otp.IsUsed = true;
                otp.IsVerified = true;
                otp.ExpiresAt = DateTime.UtcNow.AddMinutes(30);
                await _otpRepository.MarkUsedAsync(otp);

                return ApiResponse<object>.SuccessResponse(null, "Email confirmed successfully.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while verifying email code for: {Email}", email);
                return ApiResponse<object>.FailResponse(
                    "An error occurred while verifying the code.",
                    new List<string> { ex.Message }
                );
            }
        }

        /// <summary>
        /// Registers a new user in the system (email, full name, phone number, password)
        /// </summary>
        public async Task<ApiResponse<object>> Register(RegisterRequestDTO request, string? preferredLanguage = null)
        {
            try
            {
                if (!await _otpRepository.HasVerifiedAsync(request.Email, OtpPurpose.EmailVerification))
                {
                    return ApiResponse<object>.FailResponse(
                        "Please verify your email with the OTP code before registering.",
                        new List<string> { "Email not confirmed" }
                    );
                }

                if (await IsEmailExistsAsync(request.Email))
                {
                    return ApiResponse<object>.FailResponse(
                        "This email is already registered.",
                        new List<string> { "Duplicate email" }
                    );
                }

                if (await IsPhoneNumberExistsAsync(request.PhoneNumber))
                {
                    return ApiResponse<object>.FailResponse(
                        "This phone number is already registered.",
                        new List<string> { "Duplicate phone number" }
                    );
                }

                var user = new ApplicationUser
                {
                    UserName = request.Email,
                    Email = request.Email,
                    FullName = request.FullName,
                    PhoneNumber = request.PhoneNumber,
                    EmailConfirmed = true,
                    PreferredLanguage = preferredLanguage,
                    CreatedAt = DateTime.UtcNow
                };

                var result = await CreateUserAsync(user, request.Password);
                if (!result.Succeeded)
                {
                    return ApiResponse<object>.FailResponse(
                        "User creation failed.",
                        result.Errors.Select(e => e.Description).ToList()
                    );
                }

                // Consume the verified OTP so it cannot be reused
                await _otpRepository.InvalidateActiveAsync(request.Email, OtpPurpose.EmailVerification);

                var userDto = _mapper.Map<UserDTO>(user);
                return ApiResponse<object>.SuccessResponse(userDto, "Registration successful");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while registering user: {Email}", request.Email);
                return ApiResponse<object>.FailResponse(
                    "An error occurred during registration.",
                    new List<string> { ex.Message }
                );
            }
        }

        #endregion

        #region Private Helper Methods

        /// <summary>
        /// Creates a user and assigns the User role
        /// </summary>
        private async Task<IdentityResult> CreateUserAsync(ApplicationUser user, string password)
        {
            var result = await _userManager.CreateAsync(user, password);
            if (result.Succeeded)
            {
                if (!await _roleManager.RoleExistsAsync(SD.User))
                {
                    await _roleManager.CreateAsync(new ApplicationRole { Name = SD.User });
                }

                await _userManager.AddToRoleAsync(user, SD.User);
            }

            return result;
        }

        /// <summary>
        /// Checks if an email already exists
        /// </summary>
        private async Task<bool> IsEmailExistsAsync(string email)
        {
            return await _userManager.FindByEmailAsync(email) != null;
        }

        /// <summary>
        /// Checks if a phone number already exists
        /// </summary>
        private async Task<bool> IsPhoneNumberExistsAsync(string phoneNumber)
        {
            return await _userManager.Users.AnyAsync(u => u.PhoneNumber == phoneNumber);
        }

        /// <summary>
        /// Generates a random 6-digit code
        /// </summary>
        private string GenerateRandomCode() => new Random().Next(100000, 999999).ToString();

        #endregion
    }
}