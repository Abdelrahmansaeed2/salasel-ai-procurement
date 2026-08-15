using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Domain.Enums;
using Microsoft.Extensions.Configuration;
using System.Threading.Tasks;
using System.Security.Cryptography;
using System.Text;

namespace Salasel.Application.Services;

public class PayTabsService : IPayTabsService
{
    private readonly IMasterOrderRepository _orderRepository;
    private readonly IConfiguration _configuration;

    public PayTabsService(IMasterOrderRepository orderRepository, IConfiguration configuration)
    {
        _orderRepository = orderRepository;
        _configuration = configuration;
    }

    public Task<bool> VerifyWebhookSignatureAsync(string payload, string signature)
    {
        var serverKey = _configuration["PayTabs:ServerKey"];
        using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(serverKey));
        var hashBytes = hmac.ComputeHash(Encoding.UTF8.GetBytes(payload));
        var hashString = System.BitConverter.ToString(hashBytes).Replace("-", "").ToLower();

        return Task.FromResult(hashString == signature.ToLower());
    }

    public async Task ProcessPaymentCallbackAsync(string transactionReference, int orderId, bool isSuccess, decimal amount)
    {
        var order = await _orderRepository.GetByIdAsync(orderId);
        if (order == null || order.PaymentStatus == PaymentStatus.Paid) return;

        if (isSuccess)
        {
            // Verify amount
            if (order.TotalAmount != amount)
            {
                // Amount mismatch
                return;
            }

            order.PaymentStatus = PaymentStatus.Paid;
            order.PaymentMethod = PaymentMethod.PayTabs; // We need to add PayTabs to PaymentMethod Enum
            order.PaidAt = System.DateTime.UtcNow;
            
            // Assuming we add a TransactionId to MasterOrder for PayTabs too, but for now just update status
            await _orderRepository.UpdateAsync(order);
        }
    }
}
