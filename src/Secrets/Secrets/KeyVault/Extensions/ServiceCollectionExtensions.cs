using Azure.Core;
using Configuration.Extensions;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Secrets.KeyVault.Options;

namespace Secrets.KeyVault.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddKeyVaultSecrets(
        this IServiceCollection services,
        IConfiguration configuration,
        TokenCredential credential)
    {
        var section = configuration.GetSection(KeyVaultOptions.SectionName);
        section.ValidateConfigurationSection();
        section.ValidateConfigurationProperties<KeyVaultOptions>();

        services
            .AddOptions<KeyVaultOptions>()
            .Configure(section.Bind)
            .ValidateOnStart();

        return services;
    }
}
