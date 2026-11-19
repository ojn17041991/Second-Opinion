using Messaging.Http.Abstractions;
using Messaging.Http.Helpers;
using System.Net.Http.Json;

namespace Messaging.Http.Implementations;

/// <inheritdoc/>
public class HttpMessageSender(IHttpClientFactory httpClientFactory) : IHttpMessageSender
{
    /// <inheritdoc/>
    public async Task SendAsync<TRequest>(HttpMethod method, Uri baseAddress, string route, TRequest message, CancellationToken cancellationToken = default)
    {
        using var response = await SendRequestAsync(method, baseAddress, route, message, cancellationToken);
    }

    /// <inheritdoc/>
    public async Task<TResponse> SendAsync<TRequest, TResponse>(HttpMethod method, Uri baseAddress, string route, TRequest message, CancellationToken cancellationToken = default)
    {
        using var response = await SendRequestAsync(method, baseAddress, route, message, cancellationToken);

        if (response.Content.Headers.ContentType?.MediaType != "application/json")
        {
            throw new HttpRequestException(
                $"Expected a JSON response but received '{response.Content.Headers.ContentType?.MediaType ?? "no content type"}'.",
                null,
                response.StatusCode);
        }

        var result = await response.Content.ReadFromJsonAsync<TResponse>(cancellationToken);
        return result ?? throw new HttpRequestException("Response body was empty.", null, response.StatusCode);
    }

    private async Task<HttpResponseMessage> SendRequestAsync<TRequest>(HttpMethod method, Uri baseAddress, string route, TRequest message, CancellationToken cancellationToken)
    {
        var uri = UriHelper.Combine(baseAddress, route);

        using var request = new HttpRequestMessage(method, uri)
        {
            Content = JsonContent.Create(message)
        };

        var client = httpClientFactory.CreateClient();
        var response = await client.SendAsync(request, cancellationToken);

        if (response.IsSuccessStatusCode)
        {
            return response;
        }

        var errorBody = await response.Content.ReadAsStringAsync(cancellationToken);

        response.Dispose();

        throw new HttpRequestException(
            $"{method} {uri} failed with status {(int)response.StatusCode} ({response.StatusCode}). Response: {errorBody}",
            null,
            response.StatusCode);
    }
}
