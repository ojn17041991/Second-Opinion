using System.Text.Json.Serialization;

namespace Contracts.Ai.Enums
{
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum AiModel
    {
        Claude,
        Gemini,
        Gpt
    }
}
