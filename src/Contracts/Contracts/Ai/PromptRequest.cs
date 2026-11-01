using Contracts.Ai.Enums;
using System.ComponentModel.DataAnnotations;

namespace Contracts.Ai
{
    public record PromptRequest
    {
        [MinLength(20, ErrorMessage = "Prompt must be at least 20 characters long.")]
        [MaxLength(500, ErrorMessage = "Prompt must be at most 500 characters long.")]
        public required string Prompt { get; init; }

        [MinLength(1, ErrorMessage = "At least one AI model must be selected.")]
        public required HashSet<AiModel> Models { get; init; }
    }
}
