namespace Infrastructure.Options;

public class ServiceBusOptions
{
    public const string SectionName = "Worker:ServiceBus";

    public string Topic { get; set; } = string.Empty;

    public string Subscription { get; set; } = string.Empty;
}
