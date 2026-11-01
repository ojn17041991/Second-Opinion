using Contracts.Ai;

namespace Infrastructure.Ai.Abstractions
{
    public interface IAiRequestPublisher
    {
        public Task PublishAsync(PromptRequest request);
    }
}
