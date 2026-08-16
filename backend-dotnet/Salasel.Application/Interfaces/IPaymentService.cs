using Salasel.Domain.Entities;
using System.Threading.Tasks;

namespace Salasel.Application.Interfaces;

public interface IPaymentService
{
    Task<string> CreatePaymentIntentAsync(MasterOrder order);
    Task<string> RefundPaymentAsync(int orderId);
    Task<string> CreateSupplierAccountSessionAsync(int supplierId);
    Task<string> TransferFundsToSupplierAsync(int subOrderId);
    Task<string> RefundPartialAsync(int orderId, decimal amountToRefund, string? subOrderStripeTransferId = null);
}
