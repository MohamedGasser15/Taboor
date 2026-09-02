using Taboor_Domain.Entities;

namespace Taboor_Application.DTOs.Plan
{
    public class PlanDTO
    {
        public int Id { get; set; }

        public string Name { get; set; } = string.Empty;

        public string? Description { get; set; }

        public decimal Price { get; set; }

        public BillingCycle BillingCycle { get; set; }

        public int MaxBranches { get; set; }

        public int MaxServices { get; set; }

        public int MaxServicesPerBranch { get; set; }

        public bool IsActive { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime? UpdatedAt { get; set; }
    }
}
