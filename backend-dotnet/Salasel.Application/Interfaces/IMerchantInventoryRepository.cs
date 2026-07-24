using Salasel.Domain.Entities;

namespace Salasel.Domain.Interfaces
{
    public interface IMerchantInventoryRepository : IRepository<MerchantInventory>
    {
        Task<IEnumerable<MerchantInventory>> GetByMerchantIdAsync(int merchantId);
        Task<IEnumerable<MerchantInventory>> GetBelowReorderThresholdAsync(int merchantId);
        Task<MerchantInventory?> GetBySkuAsync(int merchantId, string sku);
    }
}
