using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Taboor_Domain.Entities;

namespace Taboor_Infrastructure.Configurations
{
    public class OtpCodeConfiguration : IEntityTypeConfiguration<OtpCode>
    {
        public void Configure(EntityTypeBuilder<OtpCode> builder)
        {
            builder.Property(o => o.Email)
                .IsRequired()
                .HasMaxLength(256);

            builder.Property(o => o.Code)
                .IsRequired()
                .HasMaxLength(10);

            builder.HasIndex(o => new { o.Email, o.Purpose });
        }
    }
}
