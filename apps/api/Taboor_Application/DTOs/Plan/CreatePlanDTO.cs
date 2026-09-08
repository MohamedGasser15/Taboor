using System.ComponentModel.DataAnnotations;
using Taboor_Domain.Entities;

namespace Taboor_Application.DTOs.Plan
{
    public class CreatePlanDTO
    {
        [Required(ErrorMessage = "Plan name is required")]
        [MaxLength(100, ErrorMessage = "Plan name cannot exceed 100 characters")]
        public string Name { get; set; } = string.Empty;

        [MaxLength(500, ErrorMessage = "Description cannot exceed 500 characters")]
        public string? Description { get; set; }

        [Required(ErrorMessage = "Price is required")]
        [Range(0, 1000000, ErrorMessage = "Price must be greater than or equal to 0")]
        public decimal Price { get; set; }

        [Required(ErrorMessage = "Billing cycle is required")]
        [EnumDataType(typeof(BillingCycle), ErrorMessage = "Invalid billing cycle")]
        public BillingCycle BillingCycle { get; set; }

        [Required(ErrorMessage = "MaxBranches is required")]
        [Range(1, 100000, ErrorMessage = "MaxBranches must be at least 1")]
        public int MaxBranches { get; set; }

        [Required(ErrorMessage = "MaxServices is required")]
        [Range(1, 100000, ErrorMessage = "MaxServices must be at least 1")]
        public int MaxServices { get; set; }

        [Required(ErrorMessage = "MaxServicesPerBranch is required")]
        [Range(1, 100000, ErrorMessage = "MaxServicesPerBranch must be at least 1")]
        public int MaxServicesPerBranch { get; set; }
    }
}
