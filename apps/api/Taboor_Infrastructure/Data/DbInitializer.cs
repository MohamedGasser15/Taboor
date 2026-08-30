using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Taboor_Application.Common.Constants;
using Taboor_Domain.Entities;

namespace Taboor_Infrastructure.DB
{
  /// <summary>
  /// Seeds the database with initial data (roles and default accounts) when the application starts.
  /// </summary>
  public static class DbInitializer
  {
    /// <summary>
    /// Applies pending migrations and seeds the database with default roles and accounts.
    /// </summary>
    /// <param name="db">The application database context.</param>
    /// <param name="roleManager">The role manager used to create seed roles.</param>
    /// <param name="userManager">The user manager used to create seed users.</param>
    /// <returns>A task representing the asynchronous operation.</returns>
    public static async Task InitializeAsync(
        ApplicationDbContext db,
        RoleManager<ApplicationRole> roleManager,
        UserManager<ApplicationUser> userManager)
    {
      if (db.Database.GetPendingMigrations().Any())
      {
        await db.Database.MigrateAsync();
      }

      await SeedRolesAsync(roleManager);
      await SeedUsersAsync(userManager);
    }

    private static async Task SeedRolesAsync(RoleManager<ApplicationRole> roleManager)
    {
      string[] roles = { SD.PlatformAdmin, SD.Business, SD.Customer };

      foreach (var role in roles)
      {
        if (!await roleManager.RoleExistsAsync(role))
        {
          await roleManager.CreateAsync(new ApplicationRole { Name = role });
        }
      }
    }

    private static async Task SeedUsersAsync(UserManager<ApplicationUser> userManager)
    {
      var seedUsers = new (string Email, string Password, string FullName, string PhoneNumber, string Role)[]
      {
                ("admin@taboor.com", "Admin@123", "Taboor Admin", "01000000001", SD.PlatformAdmin),
                ("customer@taboor.com", "Customer@123", "Taboor Customer", "01000000002", SD.Business),
                ("user@taboor.com", "User@123", "Taboor User", "01000000003", SD.Customer)
      };

      foreach (var seed in seedUsers)
      {
        if (await userManager.FindByEmailAsync(seed.Email) != null)
        {
          continue;
        }

        var user = new ApplicationUser
        {
          UserName = seed.Email,
          Email = seed.Email,
          FullName = seed.FullName,
          PhoneNumber = seed.PhoneNumber,
          EmailConfirmed = true,
          PreferredLanguage = "ar",
          CreatedAt = DateTime.UtcNow
        };

        var result = await userManager.CreateAsync(user, seed.Password);
        if (result.Succeeded)
        {
          await userManager.AddToRoleAsync(user, seed.Role);
        }
      }
    }
  }
}