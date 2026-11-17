using Azure.Messaging.ServiceBus;
using Messaging.ServiceBus.Abstractions;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging.Abstractions;
using Moq;
using Consumer = Messaging.ServiceBus.Implementations.ServiceBusMessageConsumer;

namespace Messaging.UnitTests.ServiceBus.Implementations.ServiceBusMessageConsumer;

public class ConsumerTests
{
    [Theory]
    [InlineData(null, "subscription", "topic")]
    [InlineData("  ", "subscription", "topic")]
    [InlineData("topic", null, "subscription")]
    [InlineData("topic", "  ", "subscription")]
    public async Task RunAsync_RejectsInvalidTopicOrSubscription(
        string? topic, string? subscription, string parameter)
    {
        await using var provider = new ServiceCollection().BuildServiceProvider();
        var client = new Mock<ServiceBusClient>();
        var consumer = CreateConsumer(client.Object, provider);

        var error = await Assert.ThrowsAsync<ArgumentException>(
            () => consumer.RunAsync(topic!, subscription!, CancellationToken.None));

        Assert.Equal(parameter, error.ParamName);
        client.Verify(c => c.CreateProcessor(
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<ServiceBusProcessorOptions>()), Times.Never);
    }

    [Fact]
    public async Task RunAsync_RejectsMissingHandlerBeforeCreatingProcessor()
    {
        await using var provider = new ServiceCollection().BuildServiceProvider();
        var client = new Mock<ServiceBusClient>();
        var consumer = CreateConsumer(client.Object, provider);

        var error = await Assert.ThrowsAsync<InvalidOperationException>(
            () => consumer.RunAsync("topic", "subscription", CancellationToken.None));

        Assert.Equal("No message handler registered.", error.Message);
        client.Verify(c => c.CreateProcessor(
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<ServiceBusProcessorOptions>()), Times.Never);
    }

    [Fact]
    public async Task RunAsync_DispatchesInSeparateScopesAndStopsOnCancellation()
    {
        var handled = new List<(string Body, Guid ScopeId, CancellationToken Token)>();
        var disposedScopes = new List<Guid>();
        await using var provider = new ServiceCollection()
            .AddScoped(_ => new ScopeMarker(disposedScopes))
            .AddScoped<IMessageHandler>(sp => new RecordingHandler(sp.GetRequiredService<ScopeMarker>(), handled))
            .BuildServiceProvider();
        var processor = new TestProcessor();
        var client = new Mock<ServiceBusClient>();
        client.Setup(c => c.CreateProcessor("topic", "subscription", It.Is<ServiceBusProcessorOptions>(
                options => options.AutoCompleteMessages)))
            .Returns(processor);
        var consumer = CreateConsumer(client.Object, provider);
        using var cancellation = new CancellationTokenSource();
        using var messageCancellation = new CancellationTokenSource();

        var run = consumer.RunAsync("topic", "subscription", cancellation.Token);
        await processor.Started.Task.WaitAsync(TimeSpan.FromSeconds(5));
        try
        {
            Assert.Single(disposedScopes);
            await processor.DeliverAsync("first", messageCancellation.Token);
            await processor.DeliverAsync("second", messageCancellation.Token);

            Assert.Equal(new[] { "first", "second" }, handled.Select(item => item.Body));
            Assert.NotEqual(handled[0].ScopeId, handled[1].ScopeId);
            Assert.All(handled, item => Assert.Equal(messageCancellation.Token, item.Token));
            Assert.All(handled, item => Assert.Contains(item.ScopeId, disposedScopes));
        }
        finally
        {
            cancellation.Cancel();
            await run.WaitAsync(TimeSpan.FromSeconds(5));
        }

        Assert.True(processor.Stopped);
    }

    [Fact]
    public async Task RunAsync_PropagatesHandlerFailures()
    {
        await using var provider = new ServiceCollection()
            .AddScoped<IMessageHandler, FailingHandler>()
            .BuildServiceProvider();
        var processor = new TestProcessor();
        var client = new Mock<ServiceBusClient>();
        client.Setup(c => c.CreateProcessor("topic", "subscription", It.IsAny<ServiceBusProcessorOptions>()))
            .Returns(processor);
        var consumer = CreateConsumer(client.Object, provider);
        using var cancellation = new CancellationTokenSource();

        var run = consumer.RunAsync("topic", "subscription", cancellation.Token);
        await processor.Started.Task.WaitAsync(TimeSpan.FromSeconds(5));
        try
        {
            var error = await Assert.ThrowsAsync<InvalidOperationException>(
                () => processor.DeliverAsync("message", CancellationToken.None));
            Assert.Equal("Handler failed.", error.Message);
        }
        finally
        {
            cancellation.Cancel();
            await run.WaitAsync(TimeSpan.FromSeconds(5));
        }
    }

    private static Consumer CreateConsumer(ServiceBusClient client, ServiceProvider provider) =>
        new(client, provider.GetRequiredService<IServiceScopeFactory>(), NullLogger<Consumer>.Instance);

    private sealed class ScopeMarker(List<Guid> disposedScopes) : IDisposable
    {
        public Guid Id { get; } = Guid.NewGuid();

        public void Dispose() => disposedScopes.Add(Id);
    }

    private sealed class RecordingHandler(
        ScopeMarker marker,
        List<(string Body, Guid ScopeId, CancellationToken Token)> handled) : IMessageHandler
    {
        public Task HandleAsync(BinaryData body, CancellationToken cancellationToken)
        {
            handled.Add((body.ToString(), marker.Id, cancellationToken));
            return Task.CompletedTask;
        }
    }

    private sealed class FailingHandler : IMessageHandler
    {
        public Task HandleAsync(BinaryData body, CancellationToken cancellationToken) =>
            throw new InvalidOperationException("Handler failed.");
    }

    private sealed class TestProcessor : ServiceBusProcessor
    {
        public TaskCompletionSource Started { get; } = new(TaskCreationOptions.RunContinuationsAsynchronously);
        public bool Stopped { get; private set; }

        public override Task StartProcessingAsync(CancellationToken cancellationToken = default)
        {
            Started.SetResult();
            return Task.CompletedTask;
        }

        public override Task StopProcessingAsync(CancellationToken cancellationToken = default)
        {
            Stopped = true;
            return Task.CompletedTask;
        }

        public override Task CloseAsync(CancellationToken cancellationToken = default) => Task.CompletedTask;

        public Task DeliverAsync(string body, CancellationToken cancellationToken)
        {
            var message = ServiceBusModelFactory.ServiceBusReceivedMessage(BinaryData.FromString(body));
            var args = new ProcessMessageEventArgs(message, Mock.Of<ServiceBusReceiver>(), cancellationToken);
            return OnProcessMessageAsync(args);
        }
    }
}
