using Infrastructure.Extensions;
using Infrastructure.Options;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;

namespace Infrastructure.UnitTests.Extensions;

public class ServiceCollectionExtensionsTests
{
    [Fact]
    public void AddWorkerServiceBus_WithCompleteSection_BindsTopicAndSubscription()
    {
        // Arrange
        var services = new ServiceCollection();
        var configuration = BuildConfiguration(new Dictionary<string, string?>
        {
            ["Worker:ServiceBus:Topic"] = "orders",
            ["Worker:ServiceBus:Subscription"] = "worker"
        });

        // Act
        services.AddWorkerServiceBus(configuration);
        var options = services.BuildServiceProvider().GetRequiredService<IOptions<ServiceBusOptions>>().Value;

        // Assert
        Assert.Equal("orders", options.Topic);
        Assert.Equal("worker", options.Subscription);
    }

    [Fact]
    public void AddWorkerServiceBus_WithMissingSection_ThrowsInvalidOperationException()
    {
        // Arrange
        var services = new ServiceCollection();
        var configuration = BuildConfiguration(new Dictionary<string, string?>());

        // Act & Assert
        Assert.Throws<InvalidOperationException>(() => services.AddWorkerServiceBus(configuration));
    }

    [Fact]
    public void AddWorkerServiceBus_WithEmptySubscription_ThrowsInvalidOperationException()
    {
        // Arrange
        var services = new ServiceCollection();
        var configuration = BuildConfiguration(new Dictionary<string, string?>
        {
            ["Worker:ServiceBus:Topic"] = "orders",
            ["Worker:ServiceBus:Subscription"] = " "
        });

        // Act & Assert
        var exception = Assert.Throws<InvalidOperationException>(() => services.AddWorkerServiceBus(configuration));
        Assert.Contains("Subscription", exception.Message);
    }

    private static IConfiguration BuildConfiguration(Dictionary<string, string?> values) =>
        new ConfigurationBuilder().AddInMemoryCollection(values).Build();
}
