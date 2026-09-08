using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Taboor_Application.Common;
using Taboor_Application.Common.Constants;
using Taboor_Application.DTOs.Plan;
using Taboor_Application.ServiceInterfaces;

namespace Taboor_API.Controllers
{
  /// <summary>
  /// Controller for Platform Admin to define and manage subscription plans.
  /// </summary>
  [Route("api/[controller]")]
  [ApiController]
  [Authorize(Roles = $"{SD.PlatformAdmin},Admin,PlatformAdmin")]
  public class PlansController : ControllerBase
  {
    private readonly IPlanService _planService;
    private readonly ILogger<PlansController> _logger;

    public PlansController(IPlanService planService, ILogger<PlansController> logger)
    {
      _planService = planService ?? throw new ArgumentNullException(nameof(planService));
      _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

        /// <summary>
        /// Retrieves all subscription plans.
        /// </summary>
        /// <param name="cancellationToken">Cancellation token.</param>
        [HttpGet]
        public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
        {
            try
            {
                _logger.LogInformation("GET /api/Plans requested");
                var response = await _planService.GetAllPlansAsync(cancellationToken);
                return StatusCode((int)response.StatusCode, response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error retrieving plans");
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while retrieving plans."
                });
            }
        }

    /// <summary>
    /// Retrieves a single plan by its ID.
    /// </summary>
    /// <param name="id">The unique identifier of the plan.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById([FromRoute] int id, CancellationToken cancellationToken)
    {
      try
      {
        _logger.LogInformation("GET /api/Plans/{Id} requested", id);
        var response = await _planService.GetPlanByIdAsync(id, cancellationToken);
        return StatusCode((int)response.StatusCode, response);
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, "Unexpected error retrieving plan with ID: {Id}", id);
        return StatusCode(500, new ProblemDetails
        {
          Title = "Internal server error",
          Detail = "An error occurred while retrieving the plan."
        });
      }
    }

    /// <summary>
    /// Creates a new subscription plan.
    /// </summary>
    /// <param name="dto">The plan creation payload.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreatePlanDTO dto, CancellationToken cancellationToken)
    {
      try
      {
        _logger.LogInformation("POST /api/Plans requested for: {Name}", dto?.Name);

        if (!ModelState.IsValid)
        {
          var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
          return BadRequest(ApiResponse<object>.FailResponse("Validation failed", errors));
        }

        var response = await _planService.CreatePlanAsync(dto!, cancellationToken);
        return StatusCode((int)response.StatusCode, response);
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, "Unexpected error creating plan: {Name}", dto?.Name);
        return StatusCode(500, new ProblemDetails
        {
          Title = "Internal server error",
          Detail = "An error occurred while creating the plan."
        });
      }
    }

    /// <summary>
    /// Updates an existing subscription plan.
    /// </summary>
    /// <param name="id">The unique identifier of the plan.</param>
    /// <param name="dto">The plan update payload.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update([FromRoute] int id, [FromBody] UpdatePlanDTO dto, CancellationToken cancellationToken)
    {
      try
      {
        _logger.LogInformation("PUT /api/Plans/{Id} requested", id);

        if (!ModelState.IsValid)
        {
          var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
          return BadRequest(ApiResponse<object>.FailResponse("Validation failed", errors));
        }

        var response = await _planService.UpdatePlanAsync(id, dto!, cancellationToken);
        return StatusCode((int)response.StatusCode, response);
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, "Unexpected error updating plan with ID: {Id}", id);
        return StatusCode(500, new ProblemDetails
        {
          Title = "Internal server error",
          Detail = "An error occurred while updating the plan."
        });
      }
    }

    /// <summary>
    /// Reactivates an inactive subscription plan.
    /// </summary>
    /// <param name="id">The unique identifier of the plan.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    [HttpPatch("{id:int}/activate")]
    public async Task<IActionResult> Activate([FromRoute] int id, CancellationToken cancellationToken)
    {
      try
      {
        _logger.LogInformation("PATCH /api/Plans/{Id}/activate requested", id);
        var response = await _planService.ActivatePlanAsync(id, cancellationToken);
        return StatusCode((int)response.StatusCode, response);
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, "Unexpected error activating plan with ID: {Id}", id);
        return StatusCode(500, new ProblemDetails
        {
          Title = "Internal server error",
          Detail = "An error occurred while activating the plan."
        });
      }
    }

        /// <summary>
        /// Soft-disables a subscription plan.
        /// </summary>
        /// <param name="id">The unique identifier of the plan.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        [HttpPatch("{id:int}/deactivate")]
        public async Task<IActionResult> Deactivate([FromRoute] int id, CancellationToken cancellationToken)
        {
            try
            {
                _logger.LogInformation("PATCH /api/Plans/{Id}/deactivate requested", id);
                var response = await _planService.DeactivatePlanAsync(id, cancellationToken);
                return StatusCode((int)response.StatusCode, response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error deactivating plan with ID: {Id}", id);
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while deactivating the plan."
                });
            }
        }

        /// <summary>
        /// Permanently deletes an inactive plan that has no associated subscriptions.
        /// </summary>
        /// <param name="id">The unique identifier of the plan.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        [HttpDelete("{id:int}")]
        public async Task<IActionResult> Delete([FromRoute] int id, CancellationToken cancellationToken)
        {
            try
            {
                _logger.LogInformation("DELETE /api/Plans/{Id} requested", id);
                var response = await _planService.DeletePlanAsync(id, cancellationToken);
                return StatusCode((int)response.StatusCode, response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error deleting plan with ID: {Id}", id);
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while deleting the plan."
                });
            }
        }
    }
}
