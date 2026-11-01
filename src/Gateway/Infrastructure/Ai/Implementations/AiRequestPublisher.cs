using Contracts.Ai;
using Infrastructure.Ai.Abstractions;
using Infrastructure.Ai.Options;
using Messaging.ServiceBus.Abstractions;
using Microsoft.Extensions.Options;

namespace Infrastructure.Ai.Implementations
{
    public class AiRequestPublisher(
        IMessagePublisher messagePublisher,
        IOptions<ServiceBusOptions> options) : IAiRequestPublisher
    {
        public async Task PublishAsync(PromptRequest request)
        {
            await messagePublisher.PublishAsync(options.Value.TopicName, request);
        }
    }
}
