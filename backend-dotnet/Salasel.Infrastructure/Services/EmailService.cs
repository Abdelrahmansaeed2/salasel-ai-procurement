using MailKit.Net.Smtp;
using MimeKit;
using MimeKit.Text;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;
using Salasel.Application.Interfaces;

namespace Salasel.Infrastructure.Services;

public class EmailService : IEmailService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<EmailService> _logger;

    public EmailService(IConfiguration configuration, ILogger<EmailService> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    public async Task SendPasswordResetEmailAsync(string toEmail, string resetToken)
    {
        try
        {
            var message = new MimeMessage();
            message.From.Add(MailboxAddress.Parse("noreply@salasel.com"));
            message.To.Add(MailboxAddress.Parse(toEmail));
            message.Subject = "Salasel - Password Reset Instructions";

            // In a real scenario, this would be a URL to the frontend app
            var resetLink = $"https://app.salasel.com/reset-password?token={resetToken}";

            message.Body = new TextPart(TextFormat.Html)
            {
                Text = $@"
                    <h2>Salasel Security</h2>
                    <p>We received a request to reset your password.</p>
                    <p>Click the link below to set a new password:</p>
                    <a href='{resetLink}'>Reset Password</a>
                    <br/><br/>
                    <p>If you did not request this, please ignore this email.</p>
                    <hr/>
                    <small><i>Confidentiality Notice: This email is intended for the authorized user only.</i></small>
                "
            };

            // SMTP config
            var host = _configuration["Smtp:Host"] ?? "smtp.gmail.com";
            var portStr = _configuration["Smtp:Port"] ?? "587";
            int port = int.TryParse(portStr, out var p) ? p : 587;
            var username = _configuration["Smtp:Username"];
            var password = _configuration["Smtp:Password"];

            _logger.LogInformation("=========================================");
            _logger.LogInformation($"ENTERPRISE EMAIL DISPATCHED to {toEmail}");
            _logger.LogInformation("=========================================");

            using var client = new SmtpClient();
            await client.ConnectAsync(host, port, MailKit.Security.SecureSocketOptions.StartTls);
            if (!string.IsNullOrEmpty(username) && !string.IsNullOrEmpty(password))
            {
                await client.AuthenticateAsync(username, password);
            }
            await client.SendAsync(message);
            await client.DisconnectAsync(true);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send enterprise password reset email.");
            // Don't throw, we don't want to crash the API if SMTP is down
        }
    }

    public async Task SendSupplierApprovalEmailAsync(string toEmail, string setupToken)
    {
        try
        {
            var message = new MimeMessage();
            message.From.Add(MailboxAddress.Parse("noreply@salasel.com"));
            message.To.Add(MailboxAddress.Parse(toEmail));
            message.Subject = "Salasel - Supplier Account Approved!";

            // Using localhost for local development testing, replace with production URL when deploying
            var setupLink = $"http://localhost:4200/reset-password?token={setupToken}";

            message.Body = new TextPart(TextFormat.Html)
            {
                Text = $@"
                    <h2>Welcome to Salasel!</h2>
                    <p>Congratulations! Your supplier account has been <strong>approved</strong> by our administration team.</p>
                    <p>You can now access your dashboard and start receiving intelligent procurement orders.</p>
                    <p>Please click the link below to securely set up your password:</p>
                    <a href='{setupLink}' style='display: inline-block; padding: 10px 20px; background-color: #2563eb; color: white; text-decoration: none; border-radius: 5px; margin: 15px 0;'>Set Up Password</a>
                    <br/><br/>
                    <p>Welcome aboard!<br/>The Salasel Team</p>
                    <hr/>
                    <small><i>Confidentiality Notice: This email is intended for the authorized user only.</i></small>
                "
            };

            // SMTP config
            var host = _configuration["Smtp:Host"] ?? "smtp.gmail.com";
            var portStr = _configuration["Smtp:Port"] ?? "587";
            int port = int.TryParse(portStr, out var p) ? p : 587;
            var username = _configuration["Smtp:Username"];
            var password = _configuration["Smtp:Password"];

            _logger.LogInformation("=========================================");
            _logger.LogInformation($"SUPPLIER APPROVAL EMAIL DISPATCHED to {toEmail}");
            _logger.LogInformation("=========================================");

            using var client = new SmtpClient();
            await client.ConnectAsync(host, port, MailKit.Security.SecureSocketOptions.StartTls);
            if (!string.IsNullOrEmpty(username) && !string.IsNullOrEmpty(password))
            {
                await client.AuthenticateAsync(username, password);
            }
            await client.SendAsync(message);
            await client.DisconnectAsync(true);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send supplier approval email.");
            // Don't throw, we don't want to crash the API if SMTP is down
        }
    }
}
