namespace Messaging.ServiceBus;

/// <summary>
/// Represents configuration settings for connecting to an Azure Service Bus namespace.
/// </summary>
/// <remarks>Set <c>FullyQualifiedNamespace</c> to the Service Bus host name</remarks>
public sealed record ServiceBusOptions
{
    /// <summary>
    /// Gets or sets the fully qualified namespace.
    /// </summary>
    /// <remarks>Use a dot-separated namespace path, for example <c>Company.Product.Feature</c>.</remarks>
    public string FullyQualifiedNamespace { get; set; } = string.Empty;
}