using Messaging.Http.Abstractions;
using Messaging.Http.Implementations;
using Microsoft.Extensions.DependencyInjection;

namespace Messaging.Http.Extensions;

/// <summary>
/// Provides extension methods for registering HTTP messaging services.
/// </summary>
public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Adds the HTTP message sender and the HTTP client factory it depends on.
    /// </summary>
    /// <param name="services">The service collection to add HTTP messaging services to.</param>
    /// <returns>The same service collection so that additional registrations can be chained.</returns>
    public static IServiceCollection AddMessagingHttp(this IServiceCollection services)
    {
        services.AddHttpClient();
        services.AddSingleton<IHttpMessageSender, HttpMessageSender>();

        return services;
    }
}
