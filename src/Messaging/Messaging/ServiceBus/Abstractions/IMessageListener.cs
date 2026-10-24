namespace Messaging.ServiceBus;

/// <summary>
/// Defines a handler for processing messages of a specified type asynchronously.
/// </summary>
/// <remarks>Implementations are typically used in message-driven workflows and should honor the provided
/// cancellation token.</remarks>
/// <typeparam name="T">The type of message to handle.</typeparam>
public interface IMessageListener<T>
{
    /// <summary>
    /// Processes a message asynchronously.
    /// </summary>
    /// <param name="message">The message to process.</param>
    /// <param name="cancellationToken">A token that can be used to cancel the asynchronous operation.</param>
    /// <returns>A task that represents the asynchronous handling operation.</returns>
    Task HandleAsync(T message, CancellationToken cancellationToken);
}