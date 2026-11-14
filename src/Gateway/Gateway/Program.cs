using Azure.Core;
using Azure.Identity;
using Infrastructure.Ai.Abstractions;
using Infrastructure.Ai.Extensions;
using Infrastructure.Ai.Implementations;
using Messaging.ServiceBus.Extensions;
using Scalar.AspNetCore;
using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddApplicationInsightsTelemetry();
builder.Logging.AddApplicationInsights();

TokenCredential credential = builder.Environment.IsDevelopment()
    ? new AzureCliCredential()
    : new ManagedIdentityCredential(
        ManagedIdentityId.FromUserAssignedClientId(
            builder.Configuration["AZURE_CLIENT_ID"]
                ?? throw new InvalidOperationException("AZURE_CLIENT_ID must be configured for the user-assigned managed identity.")
        )
    );

builder.Services
    .AddControllers()
    .AddJsonOptions(o =>
        o.JsonSerializerOptions.Converters.Add(
            new JsonStringEnumConverter(allowIntegerValues: false)
        )
    );

builder.Services.AddScoped<IAiRequestPublisher, AiRequestPublisher>();
builder.Services.AddMessaging(builder.Configuration, credential);
builder.Services.AddServiceBus(builder.Configuration);
builder.Services.AddOpenApi();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference();
}

app.MapControllers();
app.Run();