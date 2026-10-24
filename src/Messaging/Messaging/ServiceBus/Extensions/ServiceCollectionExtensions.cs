using System.Reflection;
using Azure.Core;
using Azure.Messaging.ServiceBus;
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
    /// The default configuration section name for Service Bus settings.
    /// </summary>
    private const string SectionName = "Messaging:ServiceBus";

    /// <summary>
    /// Adds Azure Service Bus messaging services to the dependency injection container by binding and validating
    /// Service Bus options, registering a singleton <see cref="ServiceBusClient"/>, and registering the message
    /// publisher implementation.
    /// </summary>
    /// <remarks>Requires a valid Service Bus configuration section matching <see cref="ServiceBusOptions"/>,
    /// including the fully qualified namespace.</remarks>
    /// <param name="services">The service collection to update.</param>
    /// <param name="configuration">The application configuration used to read the Service Bus settings section.</param>
    /// <param name="credential">The token credential used to authenticate the <see cref="ServiceBusClient"/>.</param>
    /// <returns>The same <see cref="IServiceCollection"/> instance so that additional calls can be chained.</returns>
    /// <exception cref="InvalidOperationException">The Service Bus configuration section is missing or incomplete.</exception>
    public static IServiceCollection AddServiceBusMessaging(
        this IServiceCollection services,
        IConfiguration configuration,
        TokenCredential credential)
    {
        var section = configuration.GetSection(SectionName);
        ValidateConfigurationSection(section);
        ValidateConfigurationProperties(section);

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

    /// <summary>
    /// Validates that the required ServiceBus configuration section exists.
    /// </summary>
    /// <param name="section">The configuration section to validate.</param>
    /// <exception cref="InvalidOperationException">The required ServiceBus configuration section is missing.</exception>
    private static void ValidateConfigurationSection(IConfigurationSection section)
    {
        if (!section.Exists())
        {
            throw new InvalidOperationException(
                $"ServiceBus configuration section '{SectionName}' is missing. " +
                $"Ensure it is defined in appsettings.json with expected properties.");
        }
    }

    /// <summary>
    /// Validates that all public properties of <see cref="ServiceBusOptions"/> exist in the configuration
    /// section and are not null or empty.
    /// </summary>
    /// <param name="section">The configuration section to validate.</param>
    /// <exception cref="InvalidOperationException">Thrown when a required property is missing, null, or empty.</exception>
    private static void ValidateConfigurationProperties(IConfigurationSection section)
    {
        var properties = typeof(ServiceBusOptions)
            .GetProperties(BindingFlags.Public | BindingFlags.Instance)
            .Where(p => p.CanRead && p.CanWrite && p.PropertyType == typeof(string));

        var missingOrEmptyProperties = new List<string>();

        foreach (var property in properties)
        {
            var value = section[property.Name];
            if (string.IsNullOrWhiteSpace(value))
            {
                missingOrEmptyProperties.Add(property.Name);
            }
        }

        if (missingOrEmptyProperties.Count > 0)
        {
            var propertyList = string.Join(", ", missingOrEmptyProperties);
            throw new InvalidOperationException(
                $"ServiceBus configuration is incomplete. The following required properties are missing or empty: {propertyList}. " +
                $"Ensure all properties are defined in appsettings.json under the '{SectionName}' section.");
        }
    }
}