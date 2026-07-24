using Salasel.Domain.Entities;

namespace Salasel.Domain.Interfaces
{
    public interface IVoiceProcurementLogRepository : IRepository<VoiceProcurementLog>
    {
        Task<IEnumerable<VoiceProcurementLog>> GetByMerchantIdAsync(int merchantId);
        Task<VoiceProcurementLog?> GetWithOrderTransactionAsync(int logId);
    }
}
