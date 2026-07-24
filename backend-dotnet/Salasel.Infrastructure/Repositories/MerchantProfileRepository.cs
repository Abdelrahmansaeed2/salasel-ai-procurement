using Microsoft.EntityFrameworkCore;
using Salasel.Domain.Entities;
using Salasel.Domain.Interfaces;
using Salasel.Infrastructure.Data;

namespace Salasel.Infrastructure.Repositories
{
    public class MerchantProfileRepository : Repository<MerchantsProfile>, IMerchantProfileRepository
    {
        public MerchantProfileRepository(SalaselDbContext context) : base(context)
        {
        }

        public async Task<MerchantsProfile?> GetByIdWithInventoryAsync(int merchantId)
        {
            return await _dbSet
                .Include(m => m.Inventories)
                .SingleOrDefaultAsync(m => m.MerchantID == merchantId);
        }

        public async Task<IEnumerable<MerchantsProfile>> GetVerifiedMerchantsAsync()
        {
            return await _dbSet.AsNoTracking().Where(m => m.IsVerified).ToListAsync();
        }
    }
}
