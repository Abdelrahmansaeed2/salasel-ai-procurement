using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/contact")]
[AllowAnonymous]
public class ContactController : ControllerBase
{
    [HttpPost]
    public IActionResult SubmitContactForm([FromBody] ContactFormDto request)
    {
        // In a real application, this would save to DB or send an email.
        return Ok(new { Message = "Your message has been received successfully." });
    }
}

public class ContactFormDto
{
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Subject { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
}
