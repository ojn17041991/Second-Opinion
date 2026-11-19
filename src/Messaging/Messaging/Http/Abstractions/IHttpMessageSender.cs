namespace Messaging.Http.Abstractions;

/// <summary>
/// Sends HTTP messages to endpoints supplied by the caller.
/// </summary>
public interface IHttpMessageSender
{
    /// <summary>
    /// Sends the message as JSON using the given HTTP method and ignores the response body.
    /// </summary>
    /// <typeparam name="TRequest">The type of the message to send.</typeparam>
    /// <param name="method">The HTTP method to use.</param>
    /// <param name="baseAddress">The base address. Must be absolute and end with '/'.</param>
    /// <param name="route">The route appended to the base address. Must not start with '/'.</param>
    /// <param name="message">The message to serialise as JSON.</param>
    /// <param name="cancellationToken">The token used to cancel the request.</param>
    /// <exception cref="HttpRequestException">Thrown when the response status is not a success.</exception>
    Task SendAsync<TRequest>(HttpMethod method, Uri baseAddress, string route, TRequest message, CancellationToken cancellationToken = default);

    /// <summary>
    /// Sends the message as JSON using the given HTTP method and deserialises the JSON response body.
    /// </summary>
    /// <typeparam name="TRequest">The type of the message to send.</typeparam>
    /// <typeparam name="TResponse">The type to deserialise the response body into.</typeparam>
    /// <param name="method">The HTTP method to use.</param>
    /// <param name="baseAddress">The base address. Must be absolute and end with '/'.</param>
    /// <param name="route">The route appended to the base address. Must not start with '/'.</param>
    /// <param name="message">The message to serialise as JSON.</param>
    /// <param name="cancellationToken">The token used to cancel the request.</param>
    /// <returns>The deserialised response body.</returns>
    /// <exception cref="HttpRequestException">Thrown when the response status is not a success, the content is not JSON, or the body is empty.</exception>
    Task<TResponse> SendAsync<TRequest, TResponse>(HttpMethod method, Uri baseAddress, string route, TRequest message, CancellationToken cancellationToken = default);

    /// <summary>
    /// Sends a request with no body using the given HTTP method and ignores the response body.
    /// </summary>
    /// <param name="method">The HTTP method to use.</param>
    /// <param name="baseAddress">The base address. Must be absolute and end with '/'.</param>
    /// <param name="route">The route appended to the base address. Must not start with '/'.</param>
    /// <param name="cancellationToken">The token used to cancel the request.</param>
    /// <exception cref="HttpRequestException">Thrown when the response status is not a success.</exception>
    Task SendAsync(HttpMethod method, Uri baseAddress, string route, CancellationToken cancellationToken = default);

    /// <summary>
    /// Sends a request with no body using the given HTTP method and deserialises the JSON response body.
    /// </summary>
    /// <typeparam name="TResponse">The type to deserialise the response body into.</typeparam>
    /// <param name="method">The HTTP method to use.</param>
    /// <param name="baseAddress">The base address. Must be absolute and end with '/'.</param>
    /// <param name="route">The route appended to the base address. Must not start with '/'.</param>
    /// <param name="cancellationToken">The token used to cancel the request.</param>
    /// <returns>The deserialised response body.</returns>
    /// <exception cref="HttpRequestException">Thrown when the response status is not a success, the content is not JSON, or the body is empty.</exception>
    Task<TResponse> SendAsync<TResponse>(HttpMethod method, Uri baseAddress, string route, CancellationToken cancellationToken = default);
}
