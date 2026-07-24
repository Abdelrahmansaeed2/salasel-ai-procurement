using Salasel.Domain.Entities;

namespace Salasel.Domain.Interfaces
{
    public interface IMerchantProfileRepository : IRepository<MerchantsProfile>
    {
        Task<MerchantsProfile?> GetByIdWithInventoryAsync(int merchantId);
        Task<IEnumerable<MerchantsProfile>> GetVerifiedMerchantsAsync();
    }
}
