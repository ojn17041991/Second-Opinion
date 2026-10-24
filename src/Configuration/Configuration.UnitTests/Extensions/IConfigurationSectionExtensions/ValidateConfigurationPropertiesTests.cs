using Configuration.Extensions;
using Microsoft.Extensions.Configuration;
using System.Collections.Generic;
using Xunit;

namespace Configuration.UnitTests.Extensions.IConfigurationSectionExtensions
{
    public class ValidateConfigurationPropertiesTests
    {
        [Fact]
        public void ValidateConfigurationProperties_WhenAllPropertiesHaveValidValues_DoesNotThrow()
        {
            // Arrange
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?>
                {
                    { "TestSection:StringProp", "value" },
                    { "TestSection:IntProp", "42" }
                })
                .Build();
            var section = configuration.GetSection("TestSection");

            Action action = () => section.ValidateConfigurationProperties<AllPropertiesOptionsValid>();

            // Act
            var exception = Record.Exception(action);

            // Assert
            Assert.Null(exception);
        }

        [Fact]
        public void ValidateConfigurationProperties_WhenStringPropertyIsNull_ThrowsInvalidOperationException()
        {
            // Arrange
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?>
                {
                    { "TestSection:StringProp", null }
                })
                .Build();
            var section = configuration.GetSection("TestSection");

            Action action = () => section.ValidateConfigurationProperties<StringPropertyOptions>();

            // Act
            var exception = Record.Exception(action);

            // Assert
            Assert.NotNull(exception);
            Assert.IsType<InvalidOperationException>(exception);
            Assert.Contains("StringProp", exception.Message);
        }

        [Fact]
        public void ValidateConfigurationProperties_WhenStringPropertyIsEmpty_ThrowsInvalidOperationException()
        {
            // Arrange
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?>
                {
                    { "TestSection:StringProp", "" }
                })
                .Build();
            var section = configuration.GetSection("TestSection");

            Action action = () => section.ValidateConfigurationProperties<StringPropertyOptions>();

            // Act
            var exception = Record.Exception(action);

            // Assert
            Assert.NotNull(exception);
            Assert.IsType<InvalidOperationException>(exception);
            Assert.Contains("StringProp", exception.Message);
        }

        [Fact]
        public void ValidateConfigurationProperties_WhenStringPropertyIsWhitespaceOnly_ThrowsInvalidOperationException()
        {
            // Arrange
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?>
                {
                    { "TestSection:StringProp", "   " }
                })
                .Build();
            var section = configuration.GetSection("TestSection");

            Action action = () => section.ValidateConfigurationProperties<StringPropertyOptions>();

            // Act
            var exception = Record.Exception(action);

            // Assert
            Assert.NotNull(exception);
            Assert.IsType<InvalidOperationException>(exception);
            Assert.Contains("StringProp", exception.Message);
        }

        [Fact]
        public void ValidateConfigurationProperties_WhenNonNullableIntPropertyIsNull_ThrowsInvalidOperationException()
        {
            // Arrange
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?>
                {
                    { "TestSection:IntProp", null }
                })
                .Build();
            var section = configuration.GetSection("TestSection");

            Action action = () => section.ValidateConfigurationProperties<NonNullableIntPropertyOptions>();

            // Act
            var exception = Record.Exception(action);

            // Assert
            Assert.NotNull(exception);
            Assert.IsType<InvalidOperationException>(exception);
            Assert.Contains("IntProp", exception.Message);
        }

        [Fact]
        public void ValidateConfigurationProperties_WhenNonNullableIntPropertyIsEmpty_ThrowsInvalidOperationException()
        {
            // Arrange
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?>
                {
                    { "TestSection:IntProp", "" }
                })
                .Build();
            var section = configuration.GetSection("TestSection");

            Action action = () => section.ValidateConfigurationProperties<NonNullableIntPropertyOptions>();

            // Act
            var exception = Record.Exception(action);

            // Assert
            Assert.NotNull(exception);
            Assert.IsType<InvalidOperationException>(exception);
            Assert.Contains("IntProp", exception.Message);
        }

        [Fact]
        public void ValidateConfigurationProperties_WhenNullableIntPropertyIsNull_DoesNotThrow()
        {
            // Arrange
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?>
                {
                    { "TestSection:NullableIntProp", null }
                })
                .Build();
            var section = configuration.GetSection("TestSection");

            Action action = () => section.ValidateConfigurationProperties<NullableIntPropertyOptions>();

            // Act
            var exception = Record.Exception(action);

            // Assert
            Assert.Null(exception);
        }

        [Fact]
        public void ValidateConfigurationProperties_WhenMultiplePropertiesAreInvalid_ThrowsWithAllPropertyNames()
        {
            // Arrange
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?>
                {
                    { "TestSection:StringProp1", null },
                    { "TestSection:StringProp2", "" },
                    { "TestSection:IntProp", null }
                })
                .Build();
            var section = configuration.GetSection("TestSection");

            Action action = () => section.ValidateConfigurationProperties<MultiplePropertiesOptions>();

            // Act
            var exception = Record.Exception(action);

            // Assert
            Assert.NotNull(exception);
            Assert.IsType<InvalidOperationException>(exception);
            Assert.Contains("StringProp1", exception.Message);
            Assert.Contains("StringProp2", exception.Message);
            Assert.Contains("IntProp", exception.Message);
        }

        [Fact]
        public void ValidateConfigurationProperties_WhenPropertiesAreInvalid_ExceptionMessageContainsSectionKey()
        {
            // Arrange
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?>
                {
                    { "TestSection:StringProp", null }
                })
                .Build();
            var section = configuration.GetSection("TestSection");

            Action action = () => section.ValidateConfigurationProperties<StringPropertyOptions>();

            // Act
            var exception = Record.Exception(action);

            // Assert
            Assert.NotNull(exception);
            Assert.Contains("TestSection", exception.Message);
        }

        [Fact]
        public void ValidateConfigurationProperties_WhenPublicStringPropertyIsInvalid_Throws()
        {
            // Arrange
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?>
                {
                    { "TestSection:PublicProperty", null }
                })
                .Build();
            var section = configuration.GetSection("TestSection");

            Action action = () => section.ValidateConfigurationProperties<PublicPropertyOptions>();

            // Act
            var exception = Record.Exception(action);

            // Assert
            Assert.NotNull(exception);
            Assert.IsType<InvalidOperationException>(exception);
        }

        [Fact]
        public void ValidateConfigurationProperties_WhenInternalStringPropertyIsInvalid_Throws()
        {
            // Arrange
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?>
                {
                    { "TestSection:InternalProperty", null }
                })
                .Build();
            var section = configuration.GetSection("TestSection");

            Action action = () => section.ValidateConfigurationProperties<InternalPropertyOptions>();

            // Act
            var exception = Record.Exception(action);

            // Assert
            Assert.NotNull(exception);
            Assert.IsType<InvalidOperationException>(exception);
        }

        [Fact]
        public void ValidateConfigurationProperties_WhenProtectedStringPropertyIsInvalid_Throws()
        {
            // Arrange
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?>
                {
                    { "TestSection:ProtectedProperty", null }
                })
                .Build();
            var section = configuration.GetSection("TestSection");

            Action action = () => section.ValidateConfigurationProperties<ProtectedPropertyOptions>();

            // Act
            var exception = Record.Exception(action);

            // Assert
            Assert.NotNull(exception);
            Assert.IsType<InvalidOperationException>(exception);
        }

        [Fact]
        public void ValidateConfigurationProperties_WhenPrivateStringPropertyIsInvalid_Throws()
        {
            // Arrange
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?>
                {
                    { "TestSection:PrivateProperty", null }
                })
                .Build();
            var section = configuration.GetSection("TestSection");

            Action action = () => section.ValidateConfigurationProperties<PrivatePropertyOptions>();

            // Act
            var exception = Record.Exception(action);

            // Assert
            Assert.NotNull(exception);
            Assert.IsType<InvalidOperationException>(exception);
        }

        [Fact]
        public void ValidateConfigurationProperties_WhenNonNullableIntPropertyHasValidValue_DoesNotThrow()
        {
            // Arrange
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?>
                {
                    { "TestSection:IntProp", "42" }
                })
                .Build();
            var section = configuration.GetSection("TestSection");

            Action action = () => section.ValidateConfigurationProperties<NonNullableIntPropertyOptions>();

            // Act
            var exception = Record.Exception(action);

            // Assert
            Assert.Null(exception);
        }

        [Fact]
        public void ValidateConfigurationProperties_WhenNullableTypeHasValue_DoesNotThrow()
        {
            // Arrange
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?>
                {
                    { "TestSection:NullableIntProp", "42" }
                })
                .Build();
            var section = configuration.GetSection("TestSection");

            Action action = () => section.ValidateConfigurationProperties<NullableIntPropertyOptions>();

            // Act
            var exception = Record.Exception(action);

            // Assert
            Assert.Null(exception);
        }
    }

    // Test Options Classes
    internal class AllPropertiesOptionsValid
    {
        public string? StringProp { get; set; }
        public int IntProp { get; set; }
    }

    internal class StringPropertyOptions
    {
        public string? StringProp { get; set; }
    }

    internal class NonNullableIntPropertyOptions
    {
        public int IntProp { get; set; }
    }

    internal class NullableIntPropertyOptions
    {
        public int? NullableIntProp { get; set; }
    }

    internal class MultiplePropertiesOptions
    {
        public string? StringProp1 { get; set; }
        public string? StringProp2 { get; set; }
        public int IntProp { get; set; }
    }

    internal class PublicPropertyOptions
    {
        public string? PublicProperty { get; set; }
    }

    internal class InternalPropertyOptions
    {
        internal string? InternalProperty { get; set; }
    }

    internal class ProtectedPropertyOptions
    {
        protected string? ProtectedProperty { get; set; }
    }

    internal class PrivatePropertyOptions
    {
        private string? PrivateProperty { get; set; }
    }
}
