using Salasel.Domain.Entities;
using Salasel.Domain.Enums;

namespace Salasel.Domain.Interfaces
{
    public interface IOrderTransactionRepository : IRepository<OrderTransaction>
{
        Task<IEnumerable<OrderTransaction>> GetByMerchantIdAsync(int merchantId);
        Task<IEnumerable<OrderTransaction>> GetByStatusAsync(ApprovalStatus status);
        Task<OrderTransaction?> GetWithSplitsAsync(int orderId);
    }
}
