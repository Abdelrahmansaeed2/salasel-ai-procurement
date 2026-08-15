using System.Threading.Tasks;

namespace Salasel.Application.Interfaces;

public interface IPayTabsService
{
    Task<bool> VerifyWebhookSignatureAsync(string payload, string signature);
    Task ProcessPaymentCallbackAsync(string transactionReference, int orderId, bool isSuccess, decimal amount);
}
