using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Stripe;
using System.Threading.Tasks;

namespace Salasel.Infrastructure.Services;

public class StripePaymentService : IPaymentService
{
    public StripePaymentService()
    {
    }

    public async Task<string> CreatePaymentIntentAsync(MasterOrder order)
    {
        var options = new PaymentIntentCreateOptions
        {
            Amount = (long)(order.TotalAmount * 100), // Convert to cents
            Currency = "usd",
            Metadata = new System.Collections.Generic.Dictionary<string, string>
            {
                { "MasterOrderId", order.Id.ToString() },
                { "MerchantId", order.MerchantId.ToString() }
            },
            // AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions
            // {
            //     Enabled = true,
            // }
            PaymentMethodTypes = new System.Collections.Generic.List<string> { "card" }
        };

        var service = new PaymentIntentService();
        var intent = await service.CreateAsync(options);
        
        return intent.ClientSecret;
    }

    public async Task<string> RefundPaymentAsync(string paymentIntentId)
    {
        var options = new RefundCreateOptions
        {
            PaymentIntent = paymentIntentId
        };

        var service = new RefundService();
        var refund = await service.CreateAsync(options);

        return refund.Id;
    }
}
