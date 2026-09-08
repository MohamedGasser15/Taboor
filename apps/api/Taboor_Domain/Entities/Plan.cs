namespace Taboor_Domain.Entities
{
    /// <summary>
    /// Represents a platform-level subscription plan defined and managed by Platform Admins.
    /// Business tenants subscribe to a Plan via subscriptions.
    /// </summary>
    public class Plan
    {
        public int Id { get; set; }

        public string Name { get; set; } = string.Empty;

        public string? Description { get; set; }

        public decimal Price { get; set; }

        public BillingCycle BillingCycle { get; set; }

        /// <summary>
        /// Maximum number of branches the business tenant may open.
        /// </summary>
        public int MaxBranches { get; set; }

        /// <summary>
        /// Maximum number of services allowed in the business-wide service catalog.
        /// </summary>
        public int MaxServices { get; set; }

        /// <summary>
        /// Maximum number of catalog services that may be active in a single branch at once.
        /// </summary>
        public int MaxServicesPerBranch { get; set; }

        /// <summary>
        /// Indicates whether the plan is active and available.
        /// Plans are never hard-deleted; they are soft-toggled using this flag.
        /// </summary>
        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; }

        public DateTime? UpdatedAt { get; set; }
    }
}
