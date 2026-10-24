using Azure.Core;
using Azure.Messaging.ServiceBus;
using Configuration.Extensions;
using Messaging.ServiceBus.Abstractions;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;

namespace Messaging.ServiceBus;

/// <summary>
/// Provides extension methods for registering Azure Service Bus messaging services.
/// </summary>
public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Registers Azure Service Bus messaging services, binds and validates ServiceBusOptions from configuration, and
    /// adds the message publisher dependencies.
    /// </summary>
    /// <remarks>Validates the ServiceBusOptions configuration section and its properties before use, and
    /// enables options validation at startup.</remarks>
    /// <param name="services">The service collection to add messaging services to.</param>
    /// <param name="configuration">The application configuration containing the ServiceBusOptions section.</param>
    /// <param name="credential">The token credential used to authenticate the ServiceBusClient.</param>
    /// <returns>The same service collection so that additional registrations can be chained.</returns>
    public static IServiceCollection AddServiceBusMessaging(
        this IServiceCollection services,
        IConfiguration configuration,
        TokenCredential credential)
    {
        var section = configuration.GetSection(ServiceBusOptions.SectionName);
        section.ValidateConfigurationSection();
        section.ValidateConfigurationProperties<ServiceBusOptions>();

        services
            .AddOptions<ServiceBusOptions>()
            .Configure(section.Bind)
            .ValidateOnStart();

        services.AddSingleton(sp =>
        {
            var options = sp.GetRequiredService<IOptions<ServiceBusOptions>>();
            return new ServiceBusClient(options.Value.FullyQualifiedNamespace, credential);
        });

        services.AddSingleton<IMessagePublisher, ServiceBusMessagePublisher>();

        return services;
    }
}