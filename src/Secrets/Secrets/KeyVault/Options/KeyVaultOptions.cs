namespace Secrets.KeyVault.Options;

/// <summary>
/// Represents configuration settings for connecting to Azure Key Vault.
/// </summary>
/// <remarks>Use with options binding from the "Secrets:KeyVault" configuration section.</remarks>
public class KeyVaultOptions
{
    /// <summary>
    /// Configuration section path for Key Vault secrets settings.
    /// </summary>
    public const string SectionName = "Secrets:KeyVault";

    /// <summary>
    /// Gets or sets the URL.
    /// </summary>
    public string Url { get; set; } = string.Empty;
}
