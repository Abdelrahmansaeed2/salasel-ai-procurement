using Microsoft.AspNetCore.Mvc;
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/auth")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly IEmailService _emailService;

    public AuthController(IAuthService authService, IEmailService emailService)
    {
        _authService = authService;
        _emailService = emailService;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequestDto request)
    {
        try
        {
            var result = await _authService.RegisterAsync(request);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequestDto request)
    {
        try
        {
            var result = await _authService.LoginAsync(request);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return Unauthorized(new { Message = ex.Message });
        }
    }

    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequestDto request)
    {
        var token = await _authService.GeneratePasswordResetTokenAsync(request);
        if (string.IsNullOrEmpty(token))
        {
            // Security best practice: Do not reveal if the user exists or not, but return 202 Accepted.
            return Accepted(new { Success = true, Message = "If the email is registered in our system, password reset instructions have been dispatched." });
        }
        
        // Actually dispatch the email using the Enterprise Email Service
        await _emailService.SendPasswordResetEmailAsync(request.Email, token);
        
        return Accepted(new { Success = true, Message = "Password reset instructions have been dispatched to the provided email address." });
    }

    [HttpPost("reset-password")]
    public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequestDto request)
    {
        var success = await _authService.ResetPasswordAsync(request);
        if (!success)
        {
            return BadRequest(new { Message = "Invalid or expired token." });
        }
        return Ok(new { Message = "Password reset successfully." });
    }
}
