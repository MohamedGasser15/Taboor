using Microsoft.Extensions.DependencyInjection;

namespace Taboor_Application.Config
{
    public static class ServiceContainer
    {
        public static IServiceCollection AddApplicationServices(
            this IServiceCollection services)
        {
            return services;
        }
    }
}