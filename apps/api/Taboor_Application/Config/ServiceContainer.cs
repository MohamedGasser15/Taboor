using Microsoft.Extensions.DependencyInjection;
using Taboor_Application.Services;

namespace Taboor_Application.Config
{
    public static class ServiceContainer
    {
        public static IServiceCollection AddApplicationServices(
            this IServiceCollection services)
        {
            // Auto-register all application services matching their interfaces (Scoped)
            services.Scan(scan => scan
                .FromAssembliesOf(typeof(AuthService))
                .AddClasses(classes => classes.InNamespaces("Taboor_Application.Services"))
                .AsImplementedInterfaces()
                .WithScopedLifetime());

            return services;
        }
    }
}