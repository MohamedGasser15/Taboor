using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Taboor_Domain.Entities;

namespace Taboor_Infrastructure.Configurations
{
    public class RefreshTokenConfiguration : IEntityTypeConfiguration<RefreshToken>
    {
        public void Configure(EntityTypeBuilder<RefreshToken> builder)
        {
            builder.Property(rt => rt.Token)
                .IsRequired()
                .HasMaxLength(128);

            builder.Property(rt => rt.UserId)
                .IsRequired()
                .HasMaxLength(450);

            builder.HasIndex(rt => rt.Token)
                .IsUnique();

            builder.HasOne(rt => rt.User)
                .WithMany()
                .HasForeignKey(rt => rt.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
