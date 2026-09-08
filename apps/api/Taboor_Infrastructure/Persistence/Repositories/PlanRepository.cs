using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Taboor_Domain.Entities;
using Taboor_Domain.Repositories.IRepository;
using Taboor_Infrastructure.DB;

namespace Taboor_Infrastructure.Persistence.Repositories
{
    /// <summary>
    /// Repository implementation for Plan entities.
    /// </summary>
    public class PlanRepository : Repository<Plan>, IPlanRepository
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<PlanRepository> _logger;

        public PlanRepository(ApplicationDbContext context, ILoggerFactory loggerFactory)
            : base(context, loggerFactory.CreateLogger<Repository<Plan>>())
        {
            _context = context ?? throw new ArgumentNullException(nameof(context));
            _logger = loggerFactory.CreateLogger<PlanRepository>();
        }

        public async Task<Plan?> GetByNameAsync(string name, CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrWhiteSpace(name))
                return null;

            var trimmedName = name.Trim();
            return await _context.Plans
                .FirstOrDefaultAsync(p => p.Name.ToLower() == trimmedName.ToLower(), cancellationToken);
        }

        public async Task<IReadOnlyList<Plan>> GetActivePlansAsync(CancellationToken cancellationToken = default)
        {
            return await _context.Plans
                .Where(p => p.IsActive)
                .OrderBy(p => p.Price)
                .ToListAsync(cancellationToken);
        }

        public async Task<bool> NameExistsAsync(string name, int? excludeId = null, CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrWhiteSpace(name))
                return false;

            var trimmedName = name.Trim().ToLower();
            var query = _context.Plans.AsQueryable();

            if (excludeId.HasValue)
            {
                query = query.Where(p => p.Id != excludeId.Value);
            }

            return await query.AnyAsync(p => p.Name.ToLower() == trimmedName, cancellationToken);
        }

        public async Task<bool> HasSubscriptionsAsync(int planId, CancellationToken cancellationToken = default)
        {
            // Note: When the Subscription entity is created in the next phase,
            // this will check `_context.Subscriptions.AnyAsync(s => s.PlanId == planId, cancellationToken)`.
            // Currently no subscriptions exist.
            await Task.CompletedTask;
            return false;
        }
    }
}
