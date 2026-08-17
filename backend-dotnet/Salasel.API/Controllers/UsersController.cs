using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Domain.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/users")]
[Authorize]
public class UsersController : ControllerBase
{
    private static readonly string[] SupportedLanguages = { "en", "ar" };

    private readonly IUserRepository _userRepository;
    private readonly IRepository<UserNotificationSettings> _settingsRepository;

    public UsersController(IUserRepository userRepository, IRepository<UserNotificationSettings> settingsRepository)
    {
        _userRepository = userRepository;
        _settingsRepository = settingsRepository;
    }

    // DELETE /api/v1/users/me — delete account.
    // Implemented as a soft delete (deactivate + revoke all tokens) rather
    // than a hard row delete: MerchantsProfile/SupplierProfile and their
    // order history reference the user with DeleteBehavior.Restrict, so a
    // hard delete would fail with an FK violation for any user that has
    // ever registered a shop/placed an order. Deactivating preserves that
    // history while immediately logging the user out everywhere.
    [HttpDelete("me")]
    public async Task<IActionResult> DeleteMe()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(idStr, out var userId)) return Unauthorized();

        var user = await _userRepository.GetByIdAsync(userId);
        if (user == null) return NotFound();

        user.IsActive = false;
        user.TokenVersion++; // revoke every outstanding token immediately

        await _userRepository.UpdateAsync(user);
        await _userRepository.SaveChangesAsync();

        return Ok(new { Message = "Account deleted." });
    }

    public class FcmTokenRequest { public string Token { get; set; } = string.Empty; }

    [HttpPut("me/fcm-token")]
    public async Task<IActionResult> UpdateFcmToken([FromBody] FcmTokenRequest request)
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(idStr, out var userId)) return Unauthorized();

        var user = await _userRepository.GetByIdAsync(userId);
        if (user == null) return NotFound();

        user.FcmToken = request.Token;
        await _userRepository.UpdateAsync(user);
        await _userRepository.SaveChangesAsync();

        return Ok(new { Message = "Token updated." });
    }

    // GET /api/v1/users/me/notification-settings
    [HttpGet("me/notification-settings")]
    public async Task<IActionResult> GetNotificationSettings()
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var settings = await _settingsRepository.SingleOrDefaultAsync(s => s.UserId == userId.Value);

        // No row yet just means "defaults" — don't create one until the
        // user actually changes something via PUT.
        return Ok(settings == null ? new NotificationSettingsDto() : ToDto(settings));
    }

    // PUT /api/v1/users/me/notification-settings
    [HttpPut("me/notification-settings")]
    public async Task<IActionResult> UpdateNotificationSettings([FromBody] NotificationSettingsDto request)
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var settings = await _settingsRepository.SingleOrDefaultAsync(s => s.UserId == userId.Value);

        if (settings == null)
        {
            settings = new UserNotificationSettings { UserId = userId.Value };
            ApplyDto(settings, request);
            await _settingsRepository.AddAsync(settings);
        }
        else
        {
            ApplyDto(settings, request);
            await _settingsRepository.UpdateAsync(settings);
        }

        await _settingsRepository.SaveChangesAsync();
        return Ok(ToDto(settings));
    }

    // PUT /api/v1/users/me/language — optional per the spec (a client-only
    // setting is also acceptable), implemented here so it survives a
    // reinstall/new device.
    [HttpPut("me/language")]
    public async Task<IActionResult> UpdateLanguage([FromBody] UpdateLanguageDto request)
    {
        var userId = CurrentUserId();
        if (userId == null) return Unauthorized();

        var lang = request.Language.Trim().ToLowerInvariant();
        if (!SupportedLanguages.Contains(lang))
            return BadRequest(new { Message = $"Unsupported language. Supported: {string.Join(", ", SupportedLanguages)}" });

        var user = await _userRepository.GetByIdAsync(userId.Value);
        if (user == null) return NotFound();

        user.PreferredLanguage = lang;
        await _userRepository.UpdateAsync(user);
        await _userRepository.SaveChangesAsync();

        return Ok(new { Language = lang });
    }

    private int? CurrentUserId()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(idStr, out var id) ? id : null;
    }

    private static NotificationSettingsDto ToDto(UserNotificationSettings s) => new()
    {
        PushEnabled = s.PushEnabled,
        EmailEnabled = s.EmailEnabled,
        OrderUpdates = s.OrderUpdates,
        BiddingUpdates = s.BiddingUpdates,
        InventoryAlerts = s.InventoryAlerts,
        Marketing = s.Marketing
    };

    private static void ApplyDto(UserNotificationSettings s, NotificationSettingsDto dto)
    {
        s.PushEnabled = dto.PushEnabled;
        s.EmailEnabled = dto.EmailEnabled;
        s.OrderUpdates = dto.OrderUpdates;
        s.BiddingUpdates = dto.BiddingUpdates;
        s.InventoryAlerts = dto.InventoryAlerts;
        s.Marketing = dto.Marketing;
        s.UpdatedAt = DateTime.UtcNow;
    }
}
