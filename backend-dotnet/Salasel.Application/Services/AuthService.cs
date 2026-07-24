using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using Salasel.Application.DTOs;
using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Domain.Enums;
using Salasel.Domain.Interfaces;

namespace Salasel.Application.Services;

public class AuthService : IAuthService
{
    private readonly IUserRepository _userRepository;
    private readonly IMerchantProfileRepository _merchantRepository;
    private readonly ISupplierProfileRepository _supplierRepository;
    private readonly IConfiguration _configuration;

    public AuthService(
        IUserRepository userRepository,
        IMerchantProfileRepository merchantRepository,
        ISupplierProfileRepository supplierRepository,
        IConfiguration configuration)
    {
        _userRepository = userRepository;
        _merchantRepository = merchantRepository;
        _supplierRepository = supplierRepository;
        _configuration = configuration;
    }

    public async Task<AuthResponseDto> RegisterAsync(RegisterRequestDto request)
    {
        if (await _userRepository.EmailExistsAsync(request.Email))
        {
            throw new Exception("Email already exists.");
        }

        var user = new User
        {
            FullName = request.FullName,
            Email = request.Email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            Role = request.Role,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        await _userRepository.AddAsync(user);
        await _userRepository.SaveChangesAsync();

        if (user.Role == UserRole.Merchant)
        {
            await _merchantRepository.AddAsync(new MerchantsProfile
            {
                MerchantID = user.UserID,
                ShopName = $"{user.FullName}'s Store",
                LocationLat = 0m,
                LocationLng = 0m,
                ContactPhone = "N/A",
                IsVerified = false
            });
        }
        else if (user.Role == UserRole.Supplier)
        {
            await _supplierRepository.AddAsync(new SupplierProfile
            {
                SupplierID = user.UserID,
                CompanyName = $"{user.FullName}'s Company",
                ReliabilityScore = 100m,
                PaymentTerms = "Net 30",
                IsActiveForRouting = true
            });
        }

        await _userRepository.SaveChangesAsync();

        var token = GenerateJwtToken(user, 720); // 30 days for login

        return new AuthResponseDto
        {
            UserID = user.UserID,
            Token = token,
            Role = user.Role.ToString()
        };
    }

    public async Task<AuthResponseDto> LoginAsync(LoginRequestDto request)
    {
        var user = await _userRepository.GetByEmailAsync(request.Email);
        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
        {
            throw new Exception("Invalid email or password.");
        }

        if (!user.IsActive)
        {
            throw new Exception("Account is deactivated.");
        }

        var token = GenerateJwtToken(user, 720); // 30 days

        return new AuthResponseDto
        {
            UserID = user.UserID,
            Token = token,
            Role = user.Role.ToString()
        };
    }

    public async Task<string> GeneratePasswordResetTokenAsync(ForgotPasswordRequestDto request)
    {
        var user = await _userRepository.GetByEmailAsync(request.Email);
        if (user == null)
        {
            // Do not reveal that the user does not exist
            return string.Empty;
        }

        // Generate a short-lived token (15 mins) specifically for reset
        var resetToken = GenerateJwtToken(user, 0.25);
        return resetToken;
    }

    public async Task<bool> ResetPasswordAsync(ResetPasswordRequestDto request)
    {
        try
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.ASCII.GetBytes(_configuration["Jwt:Key"]!);

            // Validate token
            tokenHandler.ValidateToken(request.Token, new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(key),
                ValidateIssuer = true,
                ValidIssuer = _configuration["Jwt:Issuer"],
                ValidateAudience = true,
                ValidAudience = _configuration["Jwt:Audience"],
                ValidateLifetime = true,
                ClockSkew = TimeSpan.Zero
            }, out SecurityToken validatedToken);

            var jwtToken = (JwtSecurityToken)validatedToken;
            var userIdStr = jwtToken.Claims.First(x => x.Type == ClaimTypes.NameIdentifier).Value;
            var userId = int.Parse(userIdStr);

            var user = await _userRepository.GetByIdAsync(userId);
            if (user == null) return false;

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            await _userRepository.UpdateAsync(user);
            await _userRepository.SaveChangesAsync();

            return true;
        }
        catch
        {
            return false;
        }
    }

    private string GenerateJwtToken(User user, double expirationHours)
    {
        var tokenHandler = new JwtSecurityTokenHandler();
        var key = Encoding.ASCII.GetBytes(_configuration["Jwt:Key"]!);
        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.UserID.ToString()),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Role, user.Role.ToString())
            }),
            Expires = DateTime.UtcNow.AddHours(expirationHours),
            Issuer = _configuration["Jwt:Issuer"],
            Audience = _configuration["Jwt:Audience"],
            SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
        };
        var token = tokenHandler.CreateToken(tokenDescriptor);
        return tokenHandler.WriteToken(token);
    }
}