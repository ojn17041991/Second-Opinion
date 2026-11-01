using Contracts.Ai;
using Infrastructure.Ai.Abstractions;
using Microsoft.AspNetCore.Mvc;

namespace Gateway.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AiController(IAiRequestPublisher aiRequestPublisher) : ControllerBase
    {
        [HttpPost("prompt")]
        public async Task<IActionResult> PostPrompt([FromBody] PromptRequest request)
        {
            await aiRequestPublisher.PublishAsync(request);

            return Ok();
        }
    }
}
