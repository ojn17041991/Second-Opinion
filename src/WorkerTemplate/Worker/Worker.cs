using Infrastructure.Options;
using Messaging.ServiceBus.Abstractions;
using Microsoft.Extensions.Options;

namespace Worker;

public class Worker(IMessageConsumer messageConsumer, IOptions<ServiceBusOptions> options) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        await messageConsumer.RunAsync(
            options.Value.Topic,
            options.Value.Subscription,
            stoppingToken);
    }
}
