using Taboor_Application.ServiceInterfaces;
using Taboor_Application.Services;
using Microsoft.Extensions.DependencyInjection;

namespace Taboor_Application.Config
{
    public static class ServiceContainer
    {
        public static IServiceCollection AddApplicationServices(
            this IServiceCollection services)
        {
            services.AddScoped<IAuthService, AuthService>();
            services.AddScoped<IUserService, UserService>();
            services.AddScoped<ITokenService, TokenService>();
            services.AddScoped<IEmailSender, EmailSender>();
            services.AddScoped<IEmailTemplateService, EmailTemplateService>();
            services.AddScoped<IExternalLoginService, ExternalLoginService>();
            services.AddScoped<IPlanService, PlanService>();

            return services;
        }
    }
}