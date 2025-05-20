using Microsoft.AspNetCore.Mvc;

namespace HelloWorldApi;

[ApiController]
[Route("[controller]")]
public class HealthController : ControllerBase
{
    [HttpGet]
    public IActionResult Get()
    {
        var response = new HealthResponse {
            Status = "healthy"
        };
        return Ok(response);
    }
}