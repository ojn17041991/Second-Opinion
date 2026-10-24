using Azure.Core;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using Moq;
using Secrets.KeyVault.Extensions;
using Secrets.KeyVault.Options;

namespace Infrastructure.UnitTests.Extensions;

public class AddKeyVaultSecretsTests
{
    private readonly Mock<TokenCredential> _mockCredential = new();

    private IConfigurationRoot CreateConfiguration(Dictionary<string, string?> values)
    {
        return new ConfigurationBuilder()
            .AddInMemoryCollection(values)
            .Build();
    }

    [Fact]
    public void AddKeyVaultSecrets_WithValidConfiguration_BindsOptionsSuccessfully()
    {
        // Arrange
        var services = new ServiceCollection();
        var expectedUrl = "https://myvault.vault.azure.net/";
        var configuration = CreateConfiguration(new Dictionary<string, string?>
        {
            { "Secrets:KeyVault:Url", expectedUrl }
        });

        // Act
        var result = services.AddKeyVaultSecrets(configuration, _mockCredential.Object);

        // Assert
        Assert.Same(services, result);
        var provider = services.BuildServiceProvider();
        var options = provider.GetRequiredService<IOptions<KeyVaultOptions>>();
        Assert.Equal(expectedUrl, options.Value.Url);
    }

    [Fact]
    public void AddKeyVaultSecrets_AllowsMethodChaining()
    {
        // Arrange
        var services = new ServiceCollection();
        var configuration = CreateConfiguration(new Dictionary<string, string?>
        {
            { "Secrets:KeyVault:Url", "https://myvault.vault.azure.net/" }
        });

        // Act
        var result = services
            .AddKeyVaultSecrets(configuration, _mockCredential.Object)
            .AddSingleton<IConfiguration>(configuration);

        // Assert
        Assert.Same(services, result);
        Assert.NotNull(services.BuildServiceProvider().GetRequiredService<IConfiguration>());
    }
}
