namespace Infrastructure.Ai.Options
{
    public class ServiceBusOptions
    {
        public const string SectionName = "Gateway:ServiceBus";

        public string TopicName { get; set; } = string.Empty;
    }
}
