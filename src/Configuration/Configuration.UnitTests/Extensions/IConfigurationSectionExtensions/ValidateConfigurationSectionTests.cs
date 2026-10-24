using Configuration.Extensions;
using Microsoft.Extensions.Configuration;

namespace Configuration.UnitTests.Extensions.IConfigurationSectionExtensions
{
    public class ValidateConfigurationSectionTests
    {
        [Fact]
        public void ValidateConfigurationSection_WhenSectionExists_DoesNotThrow()
        {
            // Arrange
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?>
                {
                    { "TestSection:Key1", "Value1" }
                })
                .Build();
            var section = configuration.GetSection("TestSection");

            // Act
            var exception = Record.Exception(() =>
                section.ValidateConfigurationSection()
            );

            // Assert
            Assert.Null(exception);
        }

        [Fact]
        public void ValidateConfigurationSection_WhenSectionMissing_ThrowsInvalidOperationException()
        {
            // Arrange
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection([])
                .Build();
            var section = configuration.GetSection("MissingSection");

            // Act
            var exception = Record.Exception(() =>
                section.ValidateConfigurationSection()
            );

            // Assert
            Assert.NotNull(exception);
            Assert.IsType<InvalidOperationException>(exception);
        }

        [Fact]
        public void ValidateConfigurationSection_WhenSectionMissing_ExceptionMessageContainsSectionKey()
        {
            // Arrange
            Dictionary<string, string?> initialData = [];
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(initialData)
                .Build();
            var section = configuration.GetSection("MissingSection");

            // Act
            var exception = Record.Exception(() =>
                section.ValidateConfigurationSection()
            );

            // Assert
            Assert.NotNull(exception);
            Assert.Contains("MissingSection", exception.Message);
        }

        [Fact]
        public void ValidateConfigurationSection_WhenSectionExistsMultipleTimes_DoesNotThrow()
        {
            // Arrange
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?>
                {
                    { "TestSection:Key1", "Value1" },
                    { "TestSection:Key2", "Value2" },
                    { "TestSection:Key3", "Value3" }
                })
                .Build();
            var section = configuration.GetSection("TestSection");

            // Act
            var exception = Record.Exception(() =>
                section.ValidateConfigurationSection()
            );

            // Assert
            Assert.Null(exception);
        }
    }
}
