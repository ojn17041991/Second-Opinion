using Messaging.ServiceBus.Abstractions;

namespace Worker;

public class Worker(IMessageConsumer messageConsumer, IConfiguration configuration) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        await messageConsumer.RunAsync(
            configuration["Worker:ServiceBus:Topic"]!,
            configuration["Worker:ServiceBus:Subscription"]!,
            stoppingToken);
    }
}
