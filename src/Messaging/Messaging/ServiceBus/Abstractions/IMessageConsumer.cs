namespace Messaging.ServiceBus.Abstractions
{
    /// <summary>
    /// Defines a contract for consuming messages from a topic subscription asynchronously.
    /// </summary>
    /// <remarks>Implementations listen for messages of a specified type and run until cancellation is
    /// requested.</remarks>
    public interface IMessageConsumer
    {
        /// <summary>
        /// Runs an asynchronous operation for the specified topic and subscription.
        /// </summary>
        /// <param name="topic">The topic name.</param>
        /// <param name="subscription">The subscription name.</param>
        /// <param name="cancellationToken">A token used to cancel the operation.</param>
        /// <returns>A task that represents the asynchronous operation.</returns>
        Task RunAsync(string topic, string subscription, CancellationToken cancellationToken);
    }
}
