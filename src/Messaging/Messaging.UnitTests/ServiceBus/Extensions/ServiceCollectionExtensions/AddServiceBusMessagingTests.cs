using Azure.Core;
using Azure.Messaging.ServiceBus;
using Messaging.ServiceBus;
using Messaging.ServiceBus.Abstractions;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Moq;

namespace Messaging.UnitTests.ServiceBus.Extensions.ServiceCollectionExtensions;

public class AddServiceBusMessagingTests
{
    private readonly Mock<TokenCredential> _mockCredential = new();

    private IConfigurationRoot CreateConfiguration(Dictionary<string, string?> values)
    {
        return new ConfigurationBuilder()
            .AddInMemoryCollection(values)
            .Build();
    }

    [Fact]
    public void AddServiceBusMessaging_WithValidConfiguration_RegistersServicesSuccessfully()
    {
        // Arrange
        var services = new ServiceCollection();
        var configuration = CreateConfiguration(new Dictionary<string, string?>
        {
            { "Messaging:ServiceBus:FullyQualifiedNamespace", "test.servicebus.windows.net" }
        });

        // Act
        var result = services.AddServiceBusMessaging(configuration, _mockCredential.Object);

        // Assert
        Assert.Same(services, result);
        var provider = services.BuildServiceProvider();
        Assert.NotNull(provider.GetRequiredService<ServiceBusClient>());
        Assert.NotNull(provider.GetRequiredService<IMessagePublisher>());
    }

    [Fact]
    public void AddServiceBusMessaging_BindsOptionsFromConfiguration()
    {
        // Arrange
        var services = new ServiceCollection();
        var expectedNamespace = "myservice.servicebus.windows.net";
        var configuration = CreateConfiguration(new Dictionary<string, string?>
        {
            { "Messaging:ServiceBus:FullyQualifiedNamespace", expectedNamespace }
        });

        services.AddServiceBusMessaging(configuration, _mockCredential.Object);
        var provider = services.BuildServiceProvider();

        // Act
        var options = provider.GetRequiredService<Microsoft.Extensions.Options.IOptions<ServiceBusOptions>>();

        // Assert
        Assert.Equal(expectedNamespace, options.Value.FullyQualifiedNamespace);
    }

    [Fact]
    public void AddServiceBusMessaging_AllowsMethodChaining()
    {
        // Arrange
        var services = new ServiceCollection();
        var configuration = CreateConfiguration(new Dictionary<string, string?>
        {
            { "Messaging:ServiceBus:FullyQualifiedNamespace", "test.servicebus.windows.net" }
        });

        // Act
        var result = services
            .AddServiceBusMessaging(configuration, _mockCredential.Object)
            .AddSingleton<IConfiguration>(configuration);

        // Assert
        Assert.Same(services, result);
        Assert.NotNull(services.BuildServiceProvider().GetRequiredService<IConfiguration>());
    }
}
