using Azure.Identity;
using Messaging.ServiceBus.Extensions;
using Secrets.KeyVault.Extensions;

var credential = new DefaultAzureCredential();
var builder = Host.CreateApplicationBuilder(args);

builder.Services.AddHostedService<Worker.Worker>();

builder.Services.AddMessaging(
    builder.Configuration,
    credential
);

builder.Services.AddSecrets(
    builder.Configuration,
    credential
);

var host = builder.Build();
host.Run();
