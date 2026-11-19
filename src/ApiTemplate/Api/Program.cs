using Azure.Core;
using Azure.Identity;
using Messaging.Http.Extensions;
using Messaging.ServiceBus.Extensions;
using Scalar.AspNetCore;
using Secrets.KeyVault.Extensions;
using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);

if (!builder.Environment.IsDevelopment())
{
    builder.Services.AddApplicationInsightsTelemetry();
    builder.Logging.AddApplicationInsights();
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

builder.Services
    .AddControllers()
    .AddJsonOptions(o =>
        o.JsonSerializerOptions.Converters.Add(
            new JsonStringEnumConverter(allowIntegerValues: false)
        )
    );

builder.Services.AddOpenApi();
builder.Services.AddMessagingServiceBus(builder.Configuration, credential);
builder.Services.AddMessagingHttp();
builder.Services.AddSecrets(builder.Configuration, credential);

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference();
}

app.MapControllers();
app.Run();
