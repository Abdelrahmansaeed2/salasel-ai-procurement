using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Salasel.Application.Interfaces;
using Salasel.Domain.Enums;
using Stripe;
using System.IO;
using System.Threading.Tasks;

namespace Salasel.API.Controllers;

[Route("api/[controller]")]
[ApiController]
public class PaymentsController : ControllerBase
{
    private readonly IPaymentService _paymentService;
    private readonly IMasterOrderRepository _orderRepository;
    private readonly IConfiguration _configuration;

    public PaymentsController(IPaymentService paymentService, IMasterOrderRepository orderRepository, IConfiguration configuration)
    {
        _paymentService = paymentService;
        _orderRepository = orderRepository;
        _configuration = configuration;
    }

    [Authorize]
    [HttpPost("create-intent/{orderId}")]
    public async Task<IActionResult> CreateIntent(int orderId)
    {
        var order = await _orderRepository.GetByIdAsync(orderId);
        if (order == null) return NotFound("Order not found");

        if (order.PaymentStatus == PaymentStatus.Paid)
            return BadRequest("Order is already paid.");

        var clientSecret = await _paymentService.CreatePaymentIntentAsync(order);
        
        return Ok(new { clientSecret });
    }

    [HttpPost("webhook")]
    public async Task<IActionResult> Webhook()
    {
        var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();
        var endpointSecret = _configuration["Stripe:WebhookSecret"];

        try
        {
            var stripeEvent = EventUtility.ConstructEvent(json,
                Request.Headers["Stripe-Signature"], endpointSecret);

            if (stripeEvent.Type == "payment_intent.succeeded")
            {
                var paymentIntent = stripeEvent.Data.Object as PaymentIntent;
                var orderIdStr = paymentIntent.Metadata["MasterOrderId"];

                if (int.TryParse(orderIdStr, out var orderId))
                {
                    var order = await _orderRepository.GetByIdAsync(orderId);
                    if (order != null)
                    {
                        order.PaymentStatus = PaymentStatus.Paid;
                        order.PaymentMethod = Salasel.Domain.Enums.PaymentMethod.Stripe;
                        order.StripePaymentIntentId = paymentIntent.Id;
                        order.PaidAt = System.DateTime.UtcNow;
                        await _orderRepository.UpdateAsync(order);
                    }
                }
            }

            return Ok();
        }
        catch (StripeException e)
        {
            return BadRequest();
        }
    }

    [Authorize(Roles = "Merchant,Admin")]
    [HttpPost("request-refund/{orderId}")]
    public async Task<IActionResult> RequestRefund(int orderId)
    {
        var order = await _orderRepository.GetByIdAsync(orderId);
        if (order == null) return NotFound("Order not found");

        if (order.PaymentStatus != Salasel.Domain.Enums.PaymentStatus.Paid || order.PaymentMethod != Salasel.Domain.Enums.PaymentMethod.Stripe)
            return BadRequest("Order is not eligible for Stripe refund.");

        order.PaymentStatus = PaymentStatus.RefundRequested;
        await _orderRepository.UpdateAsync(order);

        return Ok(new { message = "Refund requested successfully. Awaiting admin approval." });
    }

    [Authorize(Roles = "Admin")]
    [HttpPost("approve-refund/{orderId}")]
    public async Task<IActionResult> ApproveRefund(int orderId)
    {
        var order = await _orderRepository.GetByIdAsync(orderId);
        if (order == null) return NotFound("Order not found");

        if (order.PaymentStatus != PaymentStatus.RefundRequested)
            return BadRequest("No refund requested for this order.");

        if (string.IsNullOrEmpty(order.StripePaymentIntentId))
            return BadRequest("Stripe Payment Intent ID is missing.");

        var refundId = await _paymentService.RefundPaymentAsync(order.StripePaymentIntentId);
        
        order.StripeRefundId = refundId;
        order.PaymentStatus = PaymentStatus.Refunded;
        await _orderRepository.UpdateAsync(order);

        return Ok(new { message = "Refund approved and processed successfully." });
    }
}
