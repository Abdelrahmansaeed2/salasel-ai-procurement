namespace Salasel.Application.Interfaces;

public interface IEmailService
{
    Task SendPasswordResetEmailAsync(string toEmail, string resetToken);
    Task SendSupplierApprovalEmailAsync(string toEmail, string setupToken);
}
