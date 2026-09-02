using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Taboor_Domain.Entities;

namespace Taboor_Infrastructure.Configurations
{
    public class PlanConfiguration : IEntityTypeConfiguration<Plan>
    {
        public void Configure(EntityTypeBuilder<Plan> builder)
        {
            builder.ToTable("Plans");

            builder.HasKey(p => p.Id);

            builder.Property(p => p.Name)
                .IsRequired()
                .HasMaxLength(100);

            builder.HasIndex(p => p.Name)
                .IsUnique();

            builder.Property(p => p.Description)
                .HasMaxLength(500);

            builder.Property(p => p.Price)
                .HasPrecision(18, 2);

            builder.Property(p => p.BillingCycle)
                .IsRequired();

            builder.Property(p => p.MaxBranches)
                .IsRequired();

            builder.Property(p => p.MaxServices)
                .IsRequired();

            builder.Property(p => p.MaxServicesPerBranch)
                .IsRequired();

            builder.Property(p => p.IsActive)
                .HasDefaultValue(true);

            builder.Property(p => p.CreatedAt)
                .IsRequired();
        }
    }
}
