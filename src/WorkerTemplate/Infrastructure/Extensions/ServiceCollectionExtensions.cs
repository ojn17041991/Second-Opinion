using Configuration.Extensions;
using Infrastructure.Options;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Infrastructure.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddWorkerServiceBus(
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
