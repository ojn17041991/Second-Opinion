using Messaging.ServiceBus;

var builder = Host.CreateApplicationBuilder(args);
builder.Services.AddHostedService<Worker.Worker>();
builder.Services.AddServiceBusMessaging(
    builder.Configuration,
    new Azure.Identity.DefaultAzureCredential()
);

var host = builder.Build();
host.Run();
