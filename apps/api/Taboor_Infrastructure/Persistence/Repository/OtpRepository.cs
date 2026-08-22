using Taboor_Domain.Entities;
using Taboor_Domain.IRepository;
using Taboor_Infrastructure.DB;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Taboor_Infrastructure.Persistence.Repositories
{
    /// <summary>
    /// Repository implementation for managing OTP codes in the database.
    /// </summary>
    public class OtpRepository : IOtpRepository
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<OtpRepository> _logger;

        /// <summary>
        /// Initializes a new instance of the <see cref="OtpRepository"/> class.
        /// </summary>
        /// <param name="context">The application database context.</param>
        /// <param name="logger">The logger instance.</param>
        public OtpRepository(ApplicationDbContext context, ILogger<OtpRepository> logger)
        {
            _context = context ?? throw new ArgumentNullException(nameof(context));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        /// <summary>
        /// Retrieves the first valid (not used, not expired) OTP matching the given criteria.
        /// </summary>
        /// <param name="email">The email the code was sent to.</param>
        /// <param name="code">The OTP code.</param>
        /// <param name="purpose">The purpose of the code.</param>
        /// <returns>The matching OTP or null.</returns>
        public async Task<OtpCode?> GetValidAsync(string email, string code, OtpPurpose purpose)
        {
            return await _context.OtpCodes
                .Where(o => o.Email == email
                    && o.Code == code
                    && o.Purpose == purpose
                    && !o.IsUsed
                    && o.ExpiresAt > DateTime.UtcNow)
                .FirstOrDefaultAsync();
        }

        /// <summary>
        /// Checks whether a verified (email-confirmed) OTP exists for the email within its validity window.
        /// </summary>
        /// <param name="email">The email.</param>
        /// <param name="purpose">The purpose of the code.</param>
        /// <returns>True if a verified OTP exists.</returns>
        public async Task<bool> HasVerifiedAsync(string email, OtpPurpose purpose)
        {
            return await _context.OtpCodes
                .AnyAsync(o => o.Email == email
                    && o.Purpose == purpose
                    && o.IsVerified
                    && !o.IsUsed
                    && o.ExpiresAt > DateTime.UtcNow);
        }

        /// <summary>
        /// Creates a new OTP code.
        /// </summary>
        /// <param name="otp">The OTP to create.</param>
        /// <returns>A task representing the asynchronous operation.</returns>
        public async Task CreateAsync(OtpCode otp)
        {
            _context.OtpCodes.Add(otp);
            await _context.SaveChangesAsync();
        }

        /// <summary>
        /// Marks all active (unused) OTPs for the email/purpose as used.
        /// </summary>
        /// <param name="email">The email.</param>
        /// <param name="purpose">The purpose of the code.</param>
        /// <returns>A task representing the asynchronous operation.</returns>
        public async Task InvalidateActiveAsync(string email, OtpPurpose purpose)
        {
            var active = await _context.OtpCodes
                .Where(o => o.Email == email && o.Purpose == purpose && !o.IsUsed)
                .ToListAsync();

            foreach (var otp in active)
            {
                otp.IsUsed = true;
            }

            if (active.Count > 0)
            {
                await _context.SaveChangesAsync();
            }
        }

        /// <summary>
        /// Marks the given OTP as used.
        /// </summary>
        /// <param name="otp">The OTP to update.</param>
        /// <returns>A task representing the asynchronous operation.</returns>
        public async Task MarkUsedAsync(OtpCode otp)
        {
            otp.IsUsed = true;
            _context.OtpCodes.Update(otp);
            await _context.SaveChangesAsync();
        }
    }
}