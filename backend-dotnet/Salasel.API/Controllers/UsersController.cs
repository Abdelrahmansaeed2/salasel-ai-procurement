using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Salasel.Application.Interfaces;

namespace Salasel.API.Controllers;

[ApiController]
[Route("api/v1/users")]
[Authorize]
public class UsersController : ControllerBase
{
    private readonly IUserRepository _userRepository;

    public UsersController(IUserRepository userRepository)
    {
        _userRepository = userRepository;
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
}
