using Taboor_Domain.Entities;

namespace Taboor_Domain.Repositories.IRepository
{
    /// <summary>
    /// Repository interface for managing Plan entities and specialized plan queries.
    /// </summary>
    public interface IPlanRepository : IRepository<Plan>
    {
        /// <summary>
        /// Retrieves a plan by its unique name (case-insensitive).
        /// </summary>
        /// <param name="name">The plan name to search for.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>The matching Plan or null.</returns>
        Task<Plan?> GetByNameAsync(string name, CancellationToken cancellationToken = default);

        /// <summary>
        /// Retrieves all active plans.
        /// </summary>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>List of active plans.</returns>
        Task<IReadOnlyList<Plan>> GetActivePlansAsync(CancellationToken cancellationToken = default);

        /// <summary>
        /// Checks whether a plan name already exists, optionally excluding a specific plan ID (for update checks).
        /// </summary>
        /// <param name="name">The plan name.</param>
        /// <param name="excludeId">Optional ID of the plan to exclude from the check.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>True if a duplicate name exists, otherwise false.</returns>
        Task<bool> NameExistsAsync(string name, int? excludeId = null, CancellationToken cancellationToken = default);

        /// <summary>
        /// Checks whether any active or historical subscriptions exist for the specified plan ID.
        /// </summary>
        /// <param name="planId">The plan ID.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>True if the plan has associated subscriptions, otherwise false.</returns>
        Task<bool> HasSubscriptionsAsync(int planId, CancellationToken cancellationToken = default);
    }
}
