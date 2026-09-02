using AutoMapper;
using Microsoft.Extensions.Logging;
using System.Net;
using Taboor_Application.Common;
using Taboor_Application.DTOs.Plan;
using Taboor_Application.ServiceInterfaces;
using Taboor_Domain.Entities;
using Taboor_Domain.Repositories;
using Taboor_Domain.Repositories.IRepository;

namespace Taboor_Application.Services
{
    /// <summary>
    /// Service implementation for managing subscription plans.
    /// </summary>
    public class PlanService : IPlanService
    {
        private readonly IUnitOfWork _uow;
        private readonly IMapper _mapper;
        private readonly ILogger<PlanService> _logger;

        public PlanService(
            IUnitOfWork uow,
            IMapper mapper,
            ILogger<PlanService> logger)
        {
            _uow = uow ?? throw new ArgumentNullException(nameof(uow));
            _mapper = mapper ?? throw new ArgumentNullException(nameof(mapper));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        public async Task<ApiResponse<IReadOnlyList<PlanDTO>>> GetAllPlansAsync(bool? activeOnly = null, CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation("Retrieving plans (activeOnly: {ActiveOnly})", activeOnly);

                var repo = _uow.Repository<IPlanRepository>();
                IReadOnlyList<Plan> plans;

                if (activeOnly.HasValue)
                {
                    if (activeOnly.Value)
                    {
                        plans = await repo.GetActivePlansAsync(cancellationToken);
                    }
                    else
                    {
                        var allPlans = await repo.ListAllAsync(cancellationToken);
                        plans = allPlans.Where(p => !p.IsActive).OrderBy(p => p.Price).ToList();
                    }
                }
                else
                {
                    var allPlans = await repo.ListAllAsync(cancellationToken);
                    plans = allPlans.OrderBy(p => p.Price).ToList();
                }

                var dtos = _mapper.Map<IReadOnlyList<PlanDTO>>(plans);
                return ApiResponse<IReadOnlyList<PlanDTO>>.SuccessResponse(dtos);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving plans");
                return ApiResponse<IReadOnlyList<PlanDTO>>.FailResponse("Failed to retrieve plans.");
            }
        }

        public async Task<ApiResponse<PlanDTO>> GetPlanByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation("Retrieving plan by ID: {Id}", id);

                var plan = await _uow.Repository<IPlanRepository>().GetByIdAsync(id, cancellationToken);
                if (plan == null)
                {
                    _logger.LogWarning("Plan with ID {Id} not found", id);
                    var response = ApiResponse<PlanDTO>.FailResponse("Plan not found.");
                    response.StatusCode = HttpStatusCode.NotFound;
                    return response;
                }

                var dto = _mapper.Map<PlanDTO>(plan);
                return ApiResponse<PlanDTO>.SuccessResponse(dto);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving plan with ID: {Id}", id);
                return ApiResponse<PlanDTO>.FailResponse("Failed to retrieve plan.");
            }
        }

        public async Task<ApiResponse<PlanDTO>> CreatePlanAsync(CreatePlanDTO dto, CancellationToken cancellationToken = default)
        {
            try
            {
                if (dto == null)
                {
                    return ApiResponse<PlanDTO>.FailResponse("Plan data is required.");
                }

                _logger.LogInformation("Creating plan: {Name}", dto.Name);

                if (dto.MaxServicesPerBranch > dto.MaxServices)
                {
                    var response = ApiResponse<PlanDTO>.FailResponse(
                        "MaxServicesPerBranch cannot exceed MaxServices.",
                        new List<string> { "MaxServicesPerBranch must be less than or equal to MaxServices." }
                    );
                    response.StatusCode = HttpStatusCode.BadRequest;
                    return response;
                }

                var repo = _uow.Repository<IPlanRepository>();
                if (await repo.NameExistsAsync(dto.Name, cancellationToken: cancellationToken))
                {
                    _logger.LogWarning("Plan creation failed: name '{Name}' already exists", dto.Name);
                    var response = ApiResponse<PlanDTO>.FailResponse(
                        "A plan with this name already exists.",
                        new List<string> { "Plan name must be unique." }
                    );
                    response.StatusCode = HttpStatusCode.Conflict;
                    return response;
                }

                var plan = _mapper.Map<Plan>(dto);
                plan.Name = dto.Name.Trim();
                plan.CreatedAt = DateTime.UtcNow;
                plan.IsActive = true;

                await repo.AddAsync(plan, cancellationToken);
                await _uow.SaveAsync();

                _logger.LogInformation("Plan created successfully with ID: {Id}", plan.Id);

                var resultDto = _mapper.Map<PlanDTO>(plan);
                var successResponse = ApiResponse<PlanDTO>.SuccessResponse(resultDto, "Plan created successfully.");
                successResponse.StatusCode = HttpStatusCode.Created;
                return successResponse;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while creating plan: {Name}", dto?.Name);
                return ApiResponse<PlanDTO>.FailResponse("Failed to create plan.");
            }
        }

        public async Task<ApiResponse<PlanDTO>> UpdatePlanAsync(int id, UpdatePlanDTO dto, CancellationToken cancellationToken = default)
        {
            try
            {
                if (dto == null)
                {
                    return ApiResponse<PlanDTO>.FailResponse("Plan data is required.");
                }

                _logger.LogInformation("Updating plan ID: {Id}", id);

                if (dto.MaxServicesPerBranch > dto.MaxServices)
                {
                    var response = ApiResponse<PlanDTO>.FailResponse(
                        "MaxServicesPerBranch cannot exceed MaxServices.",
                        new List<string> { "MaxServicesPerBranch must be less than or equal to MaxServices." }
                    );
                    response.StatusCode = HttpStatusCode.BadRequest;
                    return response;
                }

                var repo = _uow.Repository<IPlanRepository>();
                var plan = await repo.GetByIdAsync(id, cancellationToken);
                if (plan == null)
                {
                    _logger.LogWarning("Plan with ID {Id} not found for update", id);
                    var response = ApiResponse<PlanDTO>.FailResponse("Plan not found.");
                    response.StatusCode = HttpStatusCode.NotFound;
                    return response;
                }

                if (await repo.NameExistsAsync(dto.Name, excludeId: id, cancellationToken: cancellationToken))
                {
                    _logger.LogWarning("Plan update failed: name '{Name}' already exists on another plan", dto.Name);
                    var response = ApiResponse<PlanDTO>.FailResponse(
                        "Another plan with this name already exists.",
                        new List<string> { "Plan name must be unique." }
                    );
                    response.StatusCode = HttpStatusCode.Conflict;
                    return response;
                }

                plan.Name = dto.Name.Trim();
                plan.Description = dto.Description;
                plan.Price = dto.Price;
                plan.BillingCycle = dto.BillingCycle;
                plan.MaxBranches = dto.MaxBranches;
                plan.MaxServices = dto.MaxServices;
                plan.MaxServicesPerBranch = dto.MaxServicesPerBranch;
                plan.UpdatedAt = DateTime.UtcNow;

                await repo.UpdateAsync(plan, cancellationToken);
                await _uow.SaveAsync();

                _logger.LogInformation("Plan ID {Id} updated successfully", id);

                var resultDto = _mapper.Map<PlanDTO>(plan);
                return ApiResponse<PlanDTO>.SuccessResponse(resultDto, "Plan updated successfully.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while updating plan with ID: {Id}", id);
                return ApiResponse<PlanDTO>.FailResponse("Failed to update plan.");
            }
        }

        public async Task<ApiResponse<object>> ActivatePlanAsync(int id, CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation("Activating plan ID: {Id}", id);

                var repo = _uow.Repository<IPlanRepository>();
                var plan = await repo.GetByIdAsync(id, cancellationToken);
                if (plan == null)
                {
                    _logger.LogWarning("Plan with ID {Id} not found for activation", id);
                    var response = ApiResponse<object>.FailResponse("Plan not found.");
                    response.StatusCode = HttpStatusCode.NotFound;
                    return response;
                }

                plan.IsActive = true;
                plan.UpdatedAt = DateTime.UtcNow;

                await repo.UpdateAsync(plan, cancellationToken);
                await _uow.SaveAsync();

                _logger.LogInformation("Plan ID {Id} activated successfully", id);
                return ApiResponse<object>.SuccessResponse(new { id = plan.Id, isActive = plan.IsActive }, "Plan activated successfully.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while activating plan with ID: {Id}", id);
                return ApiResponse<object>.FailResponse("Failed to activate plan.");
            }
        }

        public async Task<ApiResponse<object>> DeactivatePlanAsync(int id, CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation("Deactivating plan ID: {Id}", id);

                var repo = _uow.Repository<IPlanRepository>();
                var plan = await repo.GetByIdAsync(id, cancellationToken);
                if (plan == null)
                {
                    _logger.LogWarning("Plan with ID {Id} not found for deactivation", id);
                    var response = ApiResponse<object>.FailResponse("Plan not found.");
                    response.StatusCode = HttpStatusCode.NotFound;
                    return response;
                }

                plan.IsActive = false;
                plan.UpdatedAt = DateTime.UtcNow;

                await repo.UpdateAsync(plan, cancellationToken);
                await _uow.SaveAsync();

                _logger.LogInformation("Plan ID {Id} deactivated successfully", id);
                return ApiResponse<object>.SuccessResponse(new { id = plan.Id, isActive = plan.IsActive }, "Plan deactivated successfully.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while deactivating plan with ID: {Id}", id);
                return ApiResponse<object>.FailResponse("Failed to deactivate plan.");
            }
        }
    }
}
