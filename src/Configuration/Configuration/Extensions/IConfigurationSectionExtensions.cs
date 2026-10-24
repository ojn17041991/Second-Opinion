using Microsoft.Extensions.Configuration;
using System.Reflection;

namespace Configuration.Extensions
{
    /// <summary>
    /// Provides extension methods for validating configuration sections and required string-based option properties.
    /// </summary>
    public static class IConfigurationSectionExtensions
    {
        /// <summary>
        /// Validates that the configuration section exists.
        /// </summary>
        /// <remarks>Use during startup to fail fast when required configuration is not defined.</remarks>
        /// <param name="section">Configuration section to validate.</param>
        /// <exception cref="InvalidOperationException">The configuration section is missing.</exception>
        public static void ValidateConfigurationSection(this IConfigurationSection section)
        {
            if (!section.Exists())
            {
                throw new InvalidOperationException(
                    $"Configuration section '{section.Key}' is missing. " +
                    $"Ensure it is defined in appsettings.json with expected properties.");
            }
        }

        /// <summary>
        /// Validates that all instance readable properties on <c>T</c> are present in the specified
        /// configuration section with values.
        /// </summary>
        /// <remarks>Validation rules are based on property type:
        /// - String properties: Must not be null, empty, or whitespace.
        /// - Nullable properties: Can be null.
        /// - Non-nullable non-string properties: Must have a value in the configuration.
        /// </remarks>
        /// <typeparam name="T">The options type that defines the required configuration property names.</typeparam>
        /// <param name="section">The configuration section to validate.</param>
        /// <exception cref="InvalidOperationException">Thrown when one or more required properties are missing, null, or invalid in the
        /// configuration section.</exception>
        public static void ValidateConfigurationProperties<T>(this IConfigurationSection section) where T : class
        {
            var properties = typeof(T)
                .GetProperties(BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic)
                .Where(p => p.CanRead);

            var missingOrEmptyProperties = new List<string>();

            foreach (var property in properties)
            {
                var value = section[property.Name];

                if (property.PropertyType == typeof(string))
                {
                    if (string.IsNullOrWhiteSpace(value))
                    {
                        missingOrEmptyProperties.Add(property.Name);
                    }
                }
                else
                {
                    var isNullableType = Nullable.GetUnderlyingType(property.PropertyType) != null;
                    if (!isNullableType && string.IsNullOrWhiteSpace(value))
                    {
                        missingOrEmptyProperties.Add(property.Name);
                    }
                }
            }

            if (missingOrEmptyProperties.Count > 0)
            {
                var propertyList = string.Join(", ", missingOrEmptyProperties);
                throw new InvalidOperationException(
                    $"Configuration section '{section.Key}' is incomplete. The following required properties are missing or empty: {propertyList}. " +
                    $"Ensure all properties are defined in appsettings.json under the '{section.Key}' section.");
            }
        }
    }
}