using Azure.Messaging.ServiceBus;
using Messaging.ServiceBus.Abstractions;
using Microsoft.Extensions.Logging;
using System.Collections.Concurrent;

namespace Messaging.ServiceBus.Implementations;

/// <inheritdoc/>
public class ServiceBusMessagePublisher(ServiceBusClient client, ILogger<ServiceBusMessagePublisher> logger) : IMessagePublisher
{
    private readonly ConcurrentDictionary<string, ServiceBusSender> _senders = new();

    /// <inheritdoc/>
    public async Task PublishAsync<T>(string topic, T message, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(topic))
        {
            logger.LogError("Topic cannot be null or empty.");
            throw new ArgumentException("Topic cannot be null or empty.", nameof(topic));
        }

        if (message == null)
        {
            logger.LogError("Message cannot be null.");
            throw new ArgumentNullException(nameof(message));
        }

        var sender = _senders.GetOrAdd(topic, client.CreateSender);
        var body = new ServiceBusMessage(BinaryData.FromObjectAsJson(message))
        {
            ContentType = "application/json"
        };

        logger.LogInformation("Publishing message to topic '{Topic}'.", topic);
        await sender.SendMessageAsync(body, cancellationToken);
        logger.LogInformation("Message successfully published to topic '{Topic}'.", topic);
    }
}