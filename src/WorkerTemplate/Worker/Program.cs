using Azure.Identity;
using Messaging.ServiceBus;
using Secrets.KeyVault.Extensions;

var credential = new DefaultAzureCredential();
var builder = Host.CreateApplicationBuilder(args);

builder.Services.AddHostedService<Worker.Worker>();

builder.Services.AddServiceBusMessaging(
    builder.Configuration,
    credential
);

builder.Services.AddKeyVaultSecrets(
    builder.Configuration,
    credential
);

var host = builder.Build();
host.Run();
