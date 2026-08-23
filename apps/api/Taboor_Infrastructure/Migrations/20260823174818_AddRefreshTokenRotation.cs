using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Taboor_Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddRefreshTokenRotation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Existing tokens are stored as plaintext and can no longer be verified
            // once hashing is enabled, so purge them all.
            migrationBuilder.Sql("DELETE FROM [RefreshTokens]");

            migrationBuilder.AddColumn<bool>(
                name: "IsUsed",
                table: "RefreshTokens",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsUsed",
                table: "RefreshTokens");
        }
    }
}
