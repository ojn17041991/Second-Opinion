using System.Net;
using System.Text;
using Moq;
using Sender = Messaging.Http.Implementations.HttpMessageSender;

namespace Messaging.UnitTests.Http.Implementations.HttpMessageSender;

public class SendAsyncTests
{
    private static readonly Uri BaseAddress = new("https://host/api/");

    [Theory]
    [InlineData("POST")]
    [InlineData("PUT")]
    [InlineData("PATCH")]
    [InlineData("DELETE")]
    public async Task SendAsync_WithMethod_SendsRequestWithThatMethodToCombinedUri(string verb)
    {
        // Arrange
        var method = new HttpMethod(verb);
        var handler = new StubHandler(new HttpResponseMessage(HttpStatusCode.NoContent));
        var sender = CreateSender(handler);

        // Act
        await sender.SendAsync(method, BaseAddress, "orders", new { Id = 1 });

        // Assert
        Assert.Equal(method, handler.Request!.Method);
        Assert.Equal("https://host/api/orders", handler.Request.RequestUri!.AbsoluteUri);
    }

    [Fact]
    public async Task SendAsync_WithMessage_SerialisesBodyAsJson()
    {
        // Arrange
        var handler = new StubHandler(new HttpResponseMessage(HttpStatusCode.NoContent));
        var sender = CreateSender(handler);

        // Act
        await sender.SendAsync(HttpMethod.Post, BaseAddress, "orders", new { Id = 1, Name = "Test" });

        // Assert
        Assert.Equal("{\"id\":1,\"name\":\"Test\"}", handler.RequestBody);
    }

    [Fact]
    public async Task SendAsync_WithBaseAddressWithoutTrailingSlash_ThrowsArgumentException()
    {
        // Arrange
        var sender = CreateSender(new StubHandler(new HttpResponseMessage(HttpStatusCode.NoContent)));

        // Act & Assert
        await Assert.ThrowsAsync<ArgumentException>(() =>
            sender.SendAsync(HttpMethod.Post, new Uri("https://host/api"), "orders", new { Id = 1 }));
    }

    [Fact]
    public async Task SendAsync_WithRouteStartingWithSlash_ThrowsArgumentException()
    {
        // Arrange
        var sender = CreateSender(new StubHandler(new HttpResponseMessage(HttpStatusCode.NoContent)));

        // Act & Assert
        await Assert.ThrowsAsync<ArgumentException>(() =>
            sender.SendAsync(HttpMethod.Post, BaseAddress, "/orders", new { Id = 1 }));
    }

    [Fact]
    public async Task SendAsync_WithoutMessage_SendsRequestWithNoBody()
    {
        // Arrange
        var handler = new StubHandler(new HttpResponseMessage(HttpStatusCode.NoContent));
        var sender = CreateSender(handler);

        // Act
        await sender.SendAsync(HttpMethod.Get, BaseAddress, "orders/42");

        // Assert
        Assert.Equal(HttpMethod.Get, handler.Request!.Method);
        Assert.Equal("https://host/api/orders/42", handler.Request.RequestUri!.AbsoluteUri);
        Assert.Null(handler.RequestBody);
    }

    [Fact]
    public async Task SendAsyncWithResponseWithoutMessage_ReturnsDeserialisedResponse()
    {
        // Arrange
        var response = new HttpResponseMessage(HttpStatusCode.OK)
        {
            Content = new StringContent("{\"Id\":42}", Encoding.UTF8, "application/json")
        };
        var sender = CreateSender(new StubHandler(response));

        // Act
        var result = await sender.SendAsync<Reply>(HttpMethod.Get, BaseAddress, "orders/42");

        // Assert
        Assert.Equal(42, result.Id);
    }

    [Fact]
    public async Task SendAsync_WithNonSuccessStatus_ThrowsHttpRequestExceptionWithStatusCode()
    {
        // Arrange
        var response = new HttpResponseMessage(HttpStatusCode.BadRequest)
        {
            Content = new StringContent("{\"title\":\"Invalid\"}", Encoding.UTF8, "application/problem+json")
        };
        var sender = CreateSender(new StubHandler(response));

        // Act & Assert
        var exception = await Assert.ThrowsAsync<HttpRequestException>(() =>
            sender.SendAsync(HttpMethod.Post, BaseAddress, "orders", new { Id = 1 }));
        Assert.Equal(HttpStatusCode.BadRequest, exception.StatusCode);
    }

    [Fact]
    public async Task SendAsync_WithLongErrorBody_IncludesFullBodyInMessage()
    {
        // Arrange
        var longBody = new string('x', 2000);
        var response = new HttpResponseMessage(HttpStatusCode.InternalServerError)
        {
            Content = new StringContent(longBody, Encoding.UTF8, "text/plain")
        };
        var sender = CreateSender(new StubHandler(response));

        // Act & Assert
        var exception = await Assert.ThrowsAsync<HttpRequestException>(() =>
            sender.SendAsync(HttpMethod.Put, BaseAddress, "orders", new { Id = 1 }));
        Assert.Contains(longBody, exception.Message);
    }

    [Fact]
    public async Task SendAsyncWithResponse_WithJsonBody_ReturnsDeserialisedResponse()
    {
        // Arrange
        var response = new HttpResponseMessage(HttpStatusCode.OK)
        {
            Content = new StringContent("{\"Id\":7}", Encoding.UTF8, "application/json")
        };
        var sender = CreateSender(new StubHandler(response));

        // Act
        var result = await sender.SendAsync<object, Reply>(HttpMethod.Post, BaseAddress, "orders", new { Id = 1 });

        // Assert
        Assert.Equal(7, result.Id);
    }

    [Fact]
    public async Task SendAsyncWithResponse_WithNonJsonContent_ThrowsHttpRequestException()
    {
        // Arrange
        var response = new HttpResponseMessage(HttpStatusCode.OK)
        {
            Content = new StringContent("plain text", Encoding.UTF8, "text/plain")
        };
        var sender = CreateSender(new StubHandler(response));

        // Act & Assert
        await Assert.ThrowsAsync<HttpRequestException>(() =>
            sender.SendAsync<object, Reply>(HttpMethod.Get, BaseAddress, "orders", new { Id = 1 }));
    }

    private static Sender CreateSender(StubHandler handler)
    {
        var factory = new Mock<IHttpClientFactory>();
        factory.Setup(f => f.CreateClient(It.IsAny<string>())).Returns(() => new HttpClient(handler));
        return new Sender(factory.Object);
    }

    public record Reply(int Id);

    private sealed class StubHandler(HttpResponseMessage response) : HttpMessageHandler
    {
        public HttpRequestMessage? Request { get; private set; }

        public string? RequestBody { get; private set; }

        protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            Request = request;
            RequestBody = request.Content is null
                ? null
                : await request.Content.ReadAsStringAsync(cancellationToken);
            return response;
        }
    }
}
