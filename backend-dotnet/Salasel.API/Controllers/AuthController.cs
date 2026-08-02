using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
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

    // App launch / token restore: client calls this with the stored bearer
    // token to confirm it's still valid and fetch the current user's info.
    [HttpGet("me")]
    [Authorize]
    public async Task<IActionResult> Me()
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var me = await _authService.GetMeAsync(userId.Value);
        if (me == null) return Unauthorized(new { Message = "User no longer exists." });

        return Ok(me);
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

    // Settings screen: change password while already logged in.
    [HttpPost("change-password")]
    [Authorize]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequestDto request)
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        try
        {
            var success = await _authService.ChangePasswordAsync(userId.Value, request);
            if (!success) return NotFound(new { Message = "User not found." });

            return Ok(new { Message = "Password changed successfully. Please log in again on other devices." });
        }
        catch (Exception ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }

    // Optional token revoke: bumps the user's token version so the current
    // (and any other outstanding) token stops validating.
    [HttpPost("logout")]
    [Authorize]
    public async Task<IActionResult> Logout()
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        await _authService.LogoutAsync(userId.Value);
        return Ok(new { Message = "Logged out successfully." });
    }

    private int? CurrentUserId()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(idStr, out var id) ? id : null;
    }
}