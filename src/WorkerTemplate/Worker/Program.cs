using Azure.Core;
using Azure.Identity;
using Messaging.ServiceBus.Extensions;
using Secrets.KeyVault.Extensions;

var builder = Host.CreateApplicationBuilder(args);

if (!builder.Environment.IsDevelopment())
{
    builder.Services.AddApplicationInsightsTelemetryWorkerService();
}

TokenCredential credential;
if (builder.Environment.IsDevelopment())
{
    credential = new AzureCliCredential();
}
else
{
    credential = new ManagedIdentityCredential(
        ManagedIdentityId.FromUserAssignedClientId(
            builder.Configuration["Azure:ManagedIdentity:ClientId"]
        )
    );
}

builder.Services.AddHostedService<Worker.Worker>();
builder.Services.AddMessaging(builder.Configuration, credential);
builder.Services.AddSecrets(builder.Configuration, credential);

var host = builder.Build();
host.Run();
