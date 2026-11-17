using Azure.Messaging.ServiceBus;
using Messaging.ServiceBus.Abstractions;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace Messaging.ServiceBus.Implementations;

public class ServiceBusMessageConsumer(
    ServiceBusClient client,
    IServiceScopeFactory scopeFactory,
    ILogger<ServiceBusMessageConsumer> logger) : IMessageConsumer
{
    public async Task RunAsync(
        string topic,
        string subscription,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(topic))
        {
            logger.LogError(
                "Topic cannot be null or empty. Topic: {Topic}, subscription: {Subscription}.",
                topic,
                subscription);
            throw new ArgumentException("Topic cannot be null or empty.", nameof(topic));
        }

        if (string.IsNullOrWhiteSpace(subscription))
        {
            logger.LogError(
                "Subscription cannot be null or empty. Topic: {Topic}, subscription: {Subscription}.",
                topic,
                subscription);
            throw new ArgumentException("Subscription cannot be null or empty.", nameof(subscription));
        }

        // OJN: This is done to ensure that the message handler is registered before messages are consumed, however resolving the dependency twice is not ideal.
        await using (var scope = scopeFactory.CreateAsyncScope())
        {
            var handler = scope.ServiceProvider.GetService<IMessageHandler>();
            if (handler == null)
            {
                logger.LogError(
                    "No message handler registered for topic {Topic} and subscription {Subscription}.",
                    topic,
                    subscription);
                throw new InvalidOperationException("No message handler registered.");
            }
        }

        await using (var processor = client.CreateProcessor(
            topic,
            subscription,
            new ServiceBusProcessorOptions { AutoCompleteMessages = true }))
        {
            processor.ProcessMessageAsync += async args =>
            {
                await using (var scope = scopeFactory.CreateAsyncScope())
                {
                    var handler = scope.ServiceProvider.GetRequiredService<IMessageHandler>();
                    await handler.HandleAsync(args.Message.Body, args.CancellationToken);
                }
            };

            processor.ProcessErrorAsync += args =>
            {
                logger.LogError(
                    args.Exception,
                    "Service Bus processing failed for {EntityPath} in {FullyQualifiedNamespace}. Topic: {Topic}, subscription: {Subscription}.",
                    args.EntityPath,
                    args.FullyQualifiedNamespace,
                    topic,
                    subscription);
                return Task.CompletedTask;
            };

            await processor.StartProcessingAsync(cancellationToken);

            try
            {
                await Task.Delay(Timeout.InfiniteTimeSpan, cancellationToken);
            }
            catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested)
            {
                logger.LogWarning(
                    "Service Bus processing was cancelled for topic {Topic} and subscription {Subscription}.",
                    topic,
                    subscription);
            }
            finally
            {
                await processor.StopProcessingAsync();
            }
        }
    }
}
