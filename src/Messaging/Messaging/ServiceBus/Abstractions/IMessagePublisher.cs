namespace Messaging.ServiceBus.Abstractions;

/// <summary>
/// Defines a contract for publishing messages to a named topic asynchronously.
/// </summary>
/// <remarks>Supports publishing strongly typed message payloads and cooperative cancellation.</remarks>
public interface IMessagePublisher
{
    /// <summary>
    /// Asynchronously publishes a message to the specified topic.
    /// </summary>
    /// <typeparam name="T">The type of the message payload.</typeparam>
    /// <param name="topic">The topic to publish the message to.</param>
    /// <param name="message">The message to publish.</param>
    /// <param name="cancellationToken">A token to monitor for cancellation requests.</param>
    /// <returns>A task that represents the asynchronous publish operation.</returns>
    Task PublishAsync<T>(string topic, T message, CancellationToken cancellationToken = default);
}