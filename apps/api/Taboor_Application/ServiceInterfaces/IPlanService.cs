using Taboor_Application.Common;
using Taboor_Application.DTOs.Plan;

namespace Taboor_Application.ServiceInterfaces
{
    /// <summary>
    /// Service contract for managing subscription plans.
    /// </summary>
    public interface IPlanService
    {
        /// <summary>
        /// Retrieves all subscription plans.
        /// </summary>
        Task<ApiResponse<IReadOnlyList<PlanDTO>>> GetAllPlansAsync(CancellationToken cancellationToken = default);

        /// <summary>
        /// Retrieves a single plan by its ID.
        /// </summary>
        Task<ApiResponse<PlanDTO>> GetPlanByIdAsync(int id, CancellationToken cancellationToken = default);

        /// <summary>
        /// Creates a new subscription plan after validating uniqueness and limit rules.
        /// </summary>
        Task<ApiResponse<PlanDTO>> CreatePlanAsync(CreatePlanDTO dto, CancellationToken cancellationToken = default);

        /// <summary>
        /// Updates an existing subscription plan.
        /// </summary>
        Task<ApiResponse<PlanDTO>> UpdatePlanAsync(int id, UpdatePlanDTO dto, CancellationToken cancellationToken = default);

        /// <summary>
        /// Reactivates an inactive plan.
        /// </summary>
        Task<ApiResponse<object>> ActivatePlanAsync(int id, CancellationToken cancellationToken = default);

        /// <summary>
        /// Soft-disables a plan.
        /// </summary>
        Task<ApiResponse<object>> DeactivatePlanAsync(int id, CancellationToken cancellationToken = default);

        /// <summary>
        /// Permanently deletes an inactive plan that has no associated subscriptions.
        /// </summary>
        Task<ApiResponse<object>> DeletePlanAsync(int id, CancellationToken cancellationToken = default);
    }
}
