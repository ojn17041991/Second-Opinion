using Messaging.ServiceBus.Abstractions;
using System.Text.Json;

namespace Messaging.UnitTests.ServiceBus.Abstractions;

public class BaseMessageHandlerTests
{
    [Fact]
    public async Task HandleAsync_DeserializesBodyAndPassesCancellationTokenToHandler()
    {
        var handler = new TestHandler();
        using var cancellation = new CancellationTokenSource();

        await ((IMessageHandler)handler).HandleAsync(
            BinaryData.FromString("""{"Id":42}"""), cancellation.Token);

        Assert.Equal(42, handler.Message?.Id);
        Assert.Equal(cancellation.Token, handler.CancellationToken);
    }

    [Fact]
    public async Task HandleAsync_RejectsNullMessage()
    {
        var handler = new TestHandler();

        await Assert.ThrowsAsync<InvalidOperationException>(
            () => ((IMessageHandler)handler).HandleAsync(BinaryData.FromString("null"), CancellationToken.None));

        Assert.Null(handler.Message);
    }

    [Fact]
    public async Task HandleAsync_PropagatesInvalidJson()
    {
        var handler = new TestHandler();

        await Assert.ThrowsAsync<JsonException>(
            () => ((IMessageHandler)handler).HandleAsync(BinaryData.FromString("not-json"), CancellationToken.None));

        Assert.Null(handler.Message);
    }

    private sealed record TestMessage(int Id);

    private sealed class TestHandler : BaseMessageHandler<TestMessage>
    {
        public TestMessage? Message { get; private set; }
        public CancellationToken CancellationToken { get; private set; }

        public override Task HandleAsync(TestMessage message, CancellationToken cancellationToken)
        {
            Message = message;
            CancellationToken = cancellationToken;
            return Task.CompletedTask;
        }
    }
}
