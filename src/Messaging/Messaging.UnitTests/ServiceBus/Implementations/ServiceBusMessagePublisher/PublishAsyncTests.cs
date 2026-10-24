using Azure.Messaging.ServiceBus;
using Moq;

namespace Messaging.UnitTests.ServiceBus.Implementations.ServiceBusMessagePublisher;

public class PublishAsyncTests
{
    private readonly Mock<ServiceBusClient> _mockClient = new();
    private readonly Mock<ServiceBusSender> _mockSender = new();

    public PublishAsyncTests()
    {
        _mockClient
            .Setup(c => c.CreateSender(It.IsAny<string>()))
            .Returns(_mockSender.Object);
    }

    [Fact]
    public async Task PublishAsync_WithValidMessage_SendsMessageSuccessfully()
    {
        // Arrange
        var publisher = new Messaging.ServiceBus.ServiceBusMessagePublisher(_mockClient.Object);
        var topic = "test-topic";
        var message = new { Id = 1, Name = "Test" };

        // Act
        await publisher.PublishAsync(topic, message);

        // Assert
        _mockSender.Verify(s =>
            s.SendMessageAsync(
                It.Is<ServiceBusMessage>(x =>
                    x.Body.ToString().Contains($"\"Id\":{message.Id}") &&
                    x.Body.ToString().Contains($"\"Name\":\"{message.Name}\"")
                ),
                It.IsAny<CancellationToken>()
            ),
            Times.Once
        );
    }

    [Fact]
    public async Task PublishAsync_WithValidMessage_SetsContentTypeToApplicationJson()
    {
        // Arrange
        var publisher = new Messaging.ServiceBus.ServiceBusMessagePublisher(_mockClient.Object);
        var topic = "test-topic";
        var message = new { Id = 1, Name = "Test" };

        // Act
        await publisher.PublishAsync(topic, message);

        // Assert
        _mockSender.Verify(s =>
            s.SendMessageAsync(
                It.Is<ServiceBusMessage>(x => x.ContentType == "application/json"),
                It.IsAny<CancellationToken>()
            ),
            Times.Once
        );
    }

    [Fact]
    public async Task PublishAsync_WithSameTopic_ReusesCachedSender()
    {
        // Arrange
        var publisher = new Messaging.ServiceBus.ServiceBusMessagePublisher(_mockClient.Object);
        var topic = "test-topic";
        var message1 = new { Id = 1 };
        var message2 = new { Id = 2 };

        // Act
        await publisher.PublishAsync(topic, message1);
        await publisher.PublishAsync(topic, message2);

        // Assert
        _mockClient.Verify(c =>
            c.CreateSender(topic),
            Times.Once
        );
        _mockSender.Verify(s =>
            s.SendMessageAsync(
                It.IsAny<ServiceBusMessage>(),
                It.IsAny<CancellationToken>()
            ),
            Times.Exactly(2)
        );
    }

    [Fact]
    public async Task PublishAsync_WithDifferentTopics_CreatesMultipleSenders()
    {
        // Arrange
        var publisher = new Messaging.ServiceBus.ServiceBusMessagePublisher(_mockClient.Object);
        var topic1 = "topic-1";
        var topic2 = "topic-2";
        var message = new { Id = 1 };

        // Act
        await publisher.PublishAsync(topic1, message);
        await publisher.PublishAsync(topic2, message);

        // Assert
        _mockClient.Verify(c =>
            c.CreateSender(topic1),
            Times.Once
        );
        _mockClient.Verify(c =>
            c.CreateSender(topic2),
            Times.Once
        );
    }

    [Fact]
    public async Task PublishAsync_WithSimpleObject_SerializesMessageAsJson()
    {
        // Arrange
        var publisher = new Messaging.ServiceBus.ServiceBusMessagePublisher(_mockClient.Object);
        var topic = "test-topic";
        var message = new { Id = 1, Name = "TestMessage" };
        ServiceBusMessage? capturedMessage = null;

        _mockSender.Setup(s =>
            s.SendMessageAsync(
                It.IsAny<ServiceBusMessage>(),
                It.IsAny<CancellationToken>()
            )
        )
        .Callback<ServiceBusMessage, CancellationToken>((msg, _) => capturedMessage = msg)
        .Returns(Task.CompletedTask);

        // Act
        await publisher.PublishAsync(topic, message);

        // Assert
        Assert.NotNull(capturedMessage);
        var jsonContent = capturedMessage.Body.ToString();
        Assert.Contains($"\"Id\":{message.Id}", jsonContent);
        Assert.Contains($"\"Name\":\"{message.Name}\"", jsonContent);
    }

    [Fact]
    public async Task PublishAsync_WithComplexObject_SerializesMessageAsJson()
    {
        // Arrange
        var publisher = new Messaging.ServiceBus.ServiceBusMessagePublisher(_mockClient.Object);
        var topic = "test-topic";
        var message = new
        {
            Id = 1,
            Nested = new { Value = "nested", Count = 5 },
            Items = new[] { "a", "b", "c" }
        };
        ServiceBusMessage? capturedMessage = null;

        _mockSender.Setup(s =>
            s.SendMessageAsync(It.IsAny<ServiceBusMessage>(), It.IsAny<CancellationToken>())
        )
        .Callback<ServiceBusMessage, CancellationToken>((msg, _) => capturedMessage = msg)
        .Returns(Task.CompletedTask);

        // Act
        await publisher.PublishAsync(topic, message);

        // Assert
        Assert.NotNull(capturedMessage);
        var expectedJson = """
            {
                "Id": 1,
                "Nested": {
                    "Value": "nested",
                    "Count": 5
                },
                "Items": ["a", "b", "c"]
            }
            """;
        expectedJson = System.Text.RegularExpressions.Regex.Replace(expectedJson, @"\s+", "");
        var actualJson = capturedMessage.Body.ToString();
        Assert.Equal(expectedJson, actualJson);
    }

    [Fact]
    public async Task PublishAsync_WithCancellationToken_PropagatesCancellationToken()
    {
        // Arrange
        var publisher = new Messaging.ServiceBus.ServiceBusMessagePublisher(_mockClient.Object);
        var topic = "test-topic";
        var message = new { Id = 1 };
        var cancellationToken = new CancellationToken();

        // Act
        await publisher.PublishAsync(topic, message, cancellationToken);

        // Assert
        _mockSender.Verify(s =>
            s.SendMessageAsync(
                It.IsAny<ServiceBusMessage>(),
                cancellationToken
            ),
            Times.Once
        );
    }

    [Fact]
    public async Task PublishAsync_WhenSenderThrowsException_PropagatesException()
    {
        // Arrange
        var publisher = new Messaging.ServiceBus.ServiceBusMessagePublisher(_mockClient.Object);
        var topic = "test-topic";
        var message = new { Id = 1 };

        _mockSender.Setup(s =>
            s.SendMessageAsync(
                It.IsAny<ServiceBusMessage>(),
                It.IsAny<CancellationToken>()
            )
        )
        .Throws<InvalidOperationException>();

        // Act & Assert
        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            publisher.PublishAsync(topic, message)
        );
    }

    [Fact]
    public async Task PublishAsync_WhenClientThrowsException_PropagatesException()
    {
        // Arrange
        var mockFailingClient = new Mock<ServiceBusClient>();
        mockFailingClient.Setup(c =>
            c.CreateSender(It.IsAny<string>())
        )
        .Throws<InvalidOperationException>();

        var publisher = new Messaging.ServiceBus.ServiceBusMessagePublisher(mockFailingClient.Object);
        var topic = "test-topic";
        var message = new { Id = 1 };

        // Act & Assert
        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            publisher.PublishAsync(topic, message)
        );
    }

    [Fact]
    public async Task PublishAsync_WithNullMessage_ThrowsArgumentNullException()
    {
        // Arrange
        var publisher = new Messaging.ServiceBus.ServiceBusMessagePublisher(_mockClient.Object);
        var topic = "test-topic";
        object? message = null;

        // Act & Assert
        await Assert.ThrowsAsync<ArgumentNullException>(() =>
            publisher.PublishAsync(topic, message!)
        );
    }

    [Fact]
    public async Task PublishAsync_WithEmptyTopic_ThrowsArgumentException()
    {
        // Arrange
        var publisher = new Messaging.ServiceBus.ServiceBusMessagePublisher(_mockClient.Object);
        var topic = string.Empty;
        var message = new { Id = 1 };

        // Act & Assert
        await Assert.ThrowsAsync<ArgumentException>(() =>
            publisher.PublishAsync(topic, message)
        );
    }

    [Fact]
    public async Task PublishAsync_WithNullTopic_ThrowsArgumentException()
    {
        // Arrange
        var publisher = new Messaging.ServiceBus.ServiceBusMessagePublisher(_mockClient.Object);
        string? topic = null;
        var message = new { Id = 1 };

        // Act & Assert
        await Assert.ThrowsAsync<ArgumentException>(() =>
            publisher.PublishAsync(topic!, message)
        );
    }
}
