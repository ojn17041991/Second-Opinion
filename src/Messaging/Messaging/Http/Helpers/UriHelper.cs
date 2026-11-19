namespace Messaging.Http.Helpers;

public static class UriHelper
{
    public static Uri Combine(Uri baseAddress, string route)
    {
        ArgumentNullException.ThrowIfNull(baseAddress);
        ArgumentException.ThrowIfNullOrWhiteSpace(route);

        if (!baseAddress.IsAbsoluteUri || !baseAddress.AbsolutePath.EndsWith('/'))
        {
            throw new ArgumentException("Base address must be absolute and end with '/'.", nameof(baseAddress));
        }

        if (route.StartsWith('/'))
        {
            throw new ArgumentException("Route must not start with '/'.", nameof(route));
        }

        return new Uri(baseAddress, route);
    }
}
