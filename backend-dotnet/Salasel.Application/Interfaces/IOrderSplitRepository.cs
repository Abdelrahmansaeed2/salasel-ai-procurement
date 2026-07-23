using Salasel.Domain.Entities;
using Salasel.Domain.Enums;

namespace Salasel.Domain.Interfaces
{
    public interface IOrderSplitRepository : IRepository<OrderSplit>
    {
        Task<IEnumerable<OrderSplit>> GetByParentOrderIdAsync(int parentOrderId);
        Task<IEnumerable<OrderSplit>> GetBySupplierIdAsync(int supplierId);
        Task<IEnumerable<OrderSplit>> GetByFulfillmentStatusAsync(FulfillmentStatus status);
    }
}
