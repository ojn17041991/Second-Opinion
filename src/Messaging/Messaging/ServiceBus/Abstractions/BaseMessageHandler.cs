namespace Messaging.ServiceBus.Abstractions;

/// <summary>
/// Deserializes messages before passing them to a typed handler.
/// </summary>
/// <typeparam name="T">The type of message to handle.</typeparam>
public abstract class BaseMessageHandler<T> : IMessageHandler, IMessageHandler<T>
{
    /// <inheritdoc />
    public abstract Task HandleAsync(T message, CancellationToken cancellationToken);

    async Task IMessageHandler.HandleAsync(BinaryData body, CancellationToken cancellationToken)
    {
        var message = body.ToObjectFromJson<T>();
        if (message == null)
        {
            throw new InvalidOperationException(
                $"The Service Bus message body cannot be null for message type {typeof(T).FullName}.");
        }

        await HandleAsync(message, cancellationToken);
    }
}
