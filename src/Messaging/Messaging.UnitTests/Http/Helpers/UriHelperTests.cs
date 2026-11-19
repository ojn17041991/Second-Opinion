using Messaging.Http.Helpers;

namespace Messaging.UnitTests.Http.Helpers;

public class UriHelperTests
{
    [Fact]
    public void Combine_WithBaseAddressAndRoute_AppendsRouteToBase()
    {
        // Act
        var result = UriHelper.Combine(new Uri("https://host/api/"), "orders/42");

        // Assert
        Assert.Equal("https://host/api/orders/42", result.AbsoluteUri);
    }

    [Fact]
    public void Combine_WithNullBaseAddress_ThrowsArgumentNullException()
    {
        Assert.Throws<ArgumentNullException>(() => UriHelper.Combine(null!, "orders"));
    }

    [Fact]
    public void Combine_WithNullRoute_ThrowsArgumentNullException()
    {
        Assert.Throws<ArgumentNullException>(() => UriHelper.Combine(new Uri("https://host/api/"), null!));
    }

    [Theory]
    [InlineData("")]
    [InlineData("   ")]
    public void Combine_WithWhitespaceRoute_ThrowsArgumentException(string route)
    {
        Assert.Throws<ArgumentException>(() => UriHelper.Combine(new Uri("https://host/api/"), route));
    }

    [Fact]
    public void Combine_WithRelativeBaseAddress_ThrowsArgumentException()
    {
        Assert.Throws<ArgumentException>(() => UriHelper.Combine(new Uri("/api/", UriKind.Relative), "orders"));
    }

    [Fact]
    public void Combine_WithBaseAddressWithoutTrailingSlash_ThrowsArgumentException()
    {
        Assert.Throws<ArgumentException>(() => UriHelper.Combine(new Uri("https://host/api"), "orders"));
    }

    [Fact]
    public void Combine_WithRouteStartingWithSlash_ThrowsArgumentException()
    {
        Assert.Throws<ArgumentException>(() => UriHelper.Combine(new Uri("https://host/api/"), "/orders"));
    }
}
