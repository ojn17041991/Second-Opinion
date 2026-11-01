using Configuration.Extensions;
using Infrastructure.Ai.Options;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Infrastructure.Ai.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddServiceBus(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var section = configuration.GetSection(ServiceBusOptions.SectionName);
        section.ValidateConfigurationSection();
        section.ValidateConfigurationProperties<ServiceBusOptions>();

        services
            .AddOptions<ServiceBusOptions>()
            .Configure(section.Bind)
            .ValidateOnStart();

        return services;
    }
}
