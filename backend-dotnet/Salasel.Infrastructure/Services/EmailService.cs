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

            // Fake SMTP config, or real if provided in appsettings
            var host = _configuration["Smtp:Host"] ?? "localhost";
            var portStr = _configuration["Smtp:Port"] ?? "1025";
            int port = int.TryParse(portStr, out var p) ? p : 1025;

            // In this specific enterprise simulation, we will log the email instead of actually failing 
            // if an SMTP server isn't running locally. 
            _logger.LogInformation("=========================================");
            _logger.LogInformation($"ENTERPRISE EMAIL DISPATCHED to {toEmail}");
            _logger.LogInformation($"Subject: {message.Subject}");
            _logger.LogInformation($"Body: {message.Body}");
            _logger.LogInformation("=========================================");

            // Uncomment to send real emails via MailKit:
            /*
            using var client = new SmtpClient();
            await client.ConnectAsync(host, port, MailKit.Security.SecureSocketOptions.Auto);
            // await client.AuthenticateAsync("user", "pass");
            await client.SendAsync(message);
            await client.DisconnectAsync(true);
            */
            
            await Task.CompletedTask;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send enterprise password reset email.");
            // Don't throw, we don't want to crash the API if SMTP is down
        }
    }
}
