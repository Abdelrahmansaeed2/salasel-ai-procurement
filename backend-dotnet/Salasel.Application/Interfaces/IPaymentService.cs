using Salasel.Domain.Entities;
using System.Threading.Tasks;

namespace Salasel.Application.Interfaces;

public interface IPaymentService
{
    Task<string> CreatePaymentIntentAsync(MasterOrder order);
    Task<string> RefundPaymentAsync(int orderId);
    Task<string> CreateSupplierAccountSessionAsync(int supplierId);
    Task<string> TransferFundsToSupplierAsync(int subOrderId);
}
