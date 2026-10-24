using Azure.Messaging.ServiceBus;
using Messaging.ServiceBus.Abstractions;
using System.Collections.Concurrent;

namespace Messaging.ServiceBus;

/// <inheritdoc/>
public class ServiceBusMessagePublisher(ServiceBusClient client) : IMessagePublisher
{
    private readonly ConcurrentDictionary<string, ServiceBusSender> _senders = new();

    /// <inheritdoc/>
    public async Task PublishAsync<T>(string topic, T message, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(topic))
        {
            throw new ArgumentException("Topic cannot be null or empty.", nameof(topic));
        }

        if (message == null)
        {
            throw new ArgumentNullException(nameof(message));
        }

        var sender = _senders.GetOrAdd(topic, client.CreateSender);
        var body = new ServiceBusMessage(BinaryData.FromObjectAsJson(message))
        {
            ContentType = "application/json"
        };

        await sender.SendMessageAsync(body, cancellationToken);
    }
}