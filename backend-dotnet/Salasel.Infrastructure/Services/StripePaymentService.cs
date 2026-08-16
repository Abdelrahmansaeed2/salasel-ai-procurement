using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Stripe;
using Salasel.Domain.Enums;
using Stripe.Checkout;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;
using Salasel.Domain.Interfaces;

namespace Salasel.Infrastructure.Services;

public class StripePaymentService : IPaymentService
{
    private readonly IRepository<SupplierProfile> _supplierRepository;
    private readonly IRepository<SubOrder> _subOrderRepository;
    private readonly IRepository<MasterOrder> _masterOrderRepository;

    public StripePaymentService(
        IRepository<SupplierProfile> supplierRepository,
        IRepository<SubOrder> subOrderRepository,
        IRepository<MasterOrder> masterOrderRepository)
    {
        _supplierRepository = supplierRepository;
        _subOrderRepository = subOrderRepository;
        _masterOrderRepository = masterOrderRepository;
    }

    public async Task<string> CreatePaymentIntentAsync(MasterOrder order)
    {
        var options = new PaymentIntentCreateOptions
        {
            Amount = (long)(order.TotalAmount * 100), // Convert to cents
            Currency = "usd",
            TransferGroup = $"ORDER_{order.Id}",
            Metadata = new Dictionary<string, string>
            {
                { "MasterOrderId", order.Id.ToString() },
                { "MerchantId", order.MerchantId.ToString() }
            },
            PaymentMethodTypes = new List<string> { "card" }
        };

        var service = new PaymentIntentService();
        var intent = await service.CreateAsync(options);
        
        return intent.ClientSecret;
    }

    public async Task<string> CreateSupplierAccountSessionAsync(int supplierId)
    {
        var supplier = await _supplierRepository.GetByIdAsync(supplierId);
        if (supplier == null) throw new Exception("Supplier not found");

        if (string.IsNullOrEmpty(supplier.StripeAccountId))
        {
            var accountOptions = new AccountCreateOptions
            {
                Type = "express",
                Capabilities = new AccountCapabilitiesOptions
                {
                    Transfers = new AccountCapabilitiesTransfersOptions
                    {
                        Requested = true,
                    },
                },
            };
            var accountService = new AccountService();
            var account = await accountService.CreateAsync(accountOptions);

            supplier.StripeAccountId = account.Id;
            await _supplierRepository.UpdateAsync(supplier);
        }

        var sessionOptions = new AccountSessionCreateOptions
        {
            Account = supplier.StripeAccountId,
            Components = new AccountSessionComponentsOptions
            {
                AccountOnboarding = new AccountSessionComponentsAccountOnboardingOptions
                {
                    Enabled = true,
                },
            },
        };

        var sessionService = new AccountSessionService();
        var session = await sessionService.CreateAsync(sessionOptions);

        return session.ClientSecret;
    }

    public async Task<string> TransferFundsToSupplierAsync(int subOrderId)
    {
        var subOrder = await _subOrderRepository.GetByIdAsync(subOrderId);
        if (subOrder == null) throw new Exception("SubOrder not found");
        if (subOrder.SupplierId == null) throw new Exception("SubOrder has no assigned supplier");
        if (!string.IsNullOrEmpty(subOrder.StripeTransferId)) throw new Exception("Funds have already been transferred for this sub-order.");

        // CRITICAL SECURITY PATCH: Prevent premature payouts
        if (subOrder.Status != FulfillmentStatus.Delivered && subOrder.Status != FulfillmentStatus.ReceiptConfirmed)
            throw new Exception("Cannot transfer funds until the order is delivered or receipt is confirmed.");

        var supplier = await _supplierRepository.GetByIdAsync(subOrder.SupplierId.Value);
        if (string.IsNullOrEmpty(supplier?.StripeAccountId))
            throw new Exception("Supplier does not have a connected Stripe account");

        // Assuming 5% platform fee
        var amountToTransfer = subOrder.SubTotalAmount * 0.95m;
        var amountCents = (long)(amountToTransfer * 100);

        var transferOptions = new TransferCreateOptions
        {
            Amount = amountCents,
            Currency = "usd",
            Destination = supplier.StripeAccountId,
            TransferGroup = $"ORDER_{subOrder.MasterId}",
            Metadata = new Dictionary<string, string>
            {
                { "SubOrderId", subOrder.Id.ToString() }
            }
        };

        var transferService = new TransferService();
        var transfer = await transferService.CreateAsync(transferOptions);

        subOrder.StripeTransferId = transfer.Id;
        await _subOrderRepository.UpdateAsync(subOrder);

        return transfer.Id;
    }

    public async Task<string> RefundPaymentAsync(int orderId)
    {
        var masterOrder = await _masterOrderRepository.GetByIdAsync(orderId);
        if (masterOrder == null) throw new Exception("Order not found");
        if (string.IsNullOrEmpty(masterOrder.StripePaymentIntentId))
            throw new Exception("No Stripe payment intent linked to this order");

        // CRITICAL SECURITY PATCH: Prevent double refunds
        if (masterOrder.PaymentStatus == PaymentStatus.Refunded || !string.IsNullOrEmpty(masterOrder.StripeRefundId))
            throw new Exception("Order has already been refunded.");

        // 1. Reverse transfers to suppliers if any were already paid
        var subOrders = await _subOrderRepository.GetAllAsync();
        var orderSubOrders = subOrders.Where(s => s.MasterId == orderId && !string.IsNullOrEmpty(s.StripeTransferId) && string.IsNullOrEmpty(s.StripeTransferReversalId)).ToList();

        var transferReversalService = new TransferReversalService();
        foreach (var sub in orderSubOrders)
        {
            var reversalOptions = new TransferReversalCreateOptions { };
            var reversal = await transferReversalService.CreateAsync(sub.StripeTransferId, reversalOptions);
            
            sub.StripeTransferReversalId = reversal.Id;
            await _subOrderRepository.UpdateAsync(sub);
        }

        // 2. Refund the original payment intent back to the merchant
        var options = new RefundCreateOptions
        {
            PaymentIntent = masterOrder.StripePaymentIntentId
        };

        var service = new RefundService();
        var refund = await service.CreateAsync(options);

        masterOrder.StripeRefundId = refund.Id;
        masterOrder.PaymentStatus = Salasel.Domain.Enums.PaymentStatus.Refunded;
        await _masterOrderRepository.UpdateAsync(masterOrder);

        return refund.Id;
    }

    public async Task<string> RefundPartialAsync(int orderId, decimal amountToRefund, string? subOrderStripeTransferId = null)
    {
        var masterOrder = await _masterOrderRepository.GetByIdAsync(orderId);
        if (masterOrder == null) throw new Exception("Order not found");
        if (string.IsNullOrEmpty(masterOrder.StripePaymentIntentId))
            throw new Exception("No Stripe payment intent linked to this order");

        // 1. Reverse part of the transfer to the supplier if applicable
        if (!string.IsNullOrEmpty(subOrderStripeTransferId))
        {
            var transferReversalService = new TransferReversalService();
            var reversalOptions = new TransferReversalCreateOptions 
            { 
                Amount = (long)(amountToRefund * 0.95m * 100) // Reversing 95% from supplier (assuming 5% platform fee)
            };
            await transferReversalService.CreateAsync(subOrderStripeTransferId, reversalOptions);
        }

        // 2. Refund the amount back to the merchant
        var options = new RefundCreateOptions
        {
            PaymentIntent = masterOrder.StripePaymentIntentId,
            Amount = (long)(amountToRefund * 100)
        };

        var service = new RefundService();
        var refund = await service.CreateAsync(options);

        // Optionally, we could record partial refunds on MasterOrder.
        // masterOrder.PaymentStatus = Salasel.Domain.Enums.PaymentStatus.PartiallyRefunded;
        
        return refund.Id;
    }
}
