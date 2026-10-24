using Azure.Core;
using Azure.Identity;
using Azure.Messaging.ServiceBus;
using Messaging.ServiceBus.Abstractions;
using Microsoft.Extensions.Azure;
using Microsoft.Extensions.DependencyInjection;

namespace Messaging.ServiceBus;

/// <summary>
/// Provides extension methods for registering Azure Service Bus messaging services in an <see
/// cref="IServiceCollection"/>.
/// </summary>
/// <remarks>Registers and configures <see cref="ServiceBusOptions"/>, adds a singleton <see
/// cref="ServiceBusClient"/> created with <see cref="DefaultAzureCredential"/>, and registers <see
/// cref="IMessagePublisher"/> with <see cref="ServiceBusMessagePublisher"/>.</remarks>
public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Adds Azure Service Bus messaging services to the dependency injection container.
    /// </summary>
    /// <remarks>Registers <c>ServiceBusClient</c> as a singleton using the configured fully qualified
    /// namespace and <c>DefaultAzureCredential</c>, and registers <c>IMessagePublisher</c> with
    /// <c>ServiceBusMessagePublisher</c> as a singleton.</remarks>
    /// <param name="services">The service collection to add registrations to.</param>
    /// <param name="options">Configures the <c>ServiceBusOptions</c> used to create the <c>ServiceBusClient</c>.</param>
    /// <param name="credential">The <c>TokenCredential</c> used to authenticate with Azure Service Bus.</param>
    /// <returns>The same service collection so additional calls can be chained.</returns>
    public static IServiceCollection AddServiceBusMessaging(
        this IServiceCollection services,
        ServiceBusOptions options,
        TokenCredential credential)
    {
        services.AddAzureClients(builder =>
        {
            builder.AddServiceBusClientWithNamespace(options.FullyQualifiedNamespace).WithCredential(credential);
        });

        services.AddSingleton(options);
        services.AddSingleton<IMessagePublisher, ServiceBusMessagePublisher>();

        return services;
    }
}