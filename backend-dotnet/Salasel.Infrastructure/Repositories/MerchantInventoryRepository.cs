using Salasel.Domain.Entities;
using Salasel.Infrastructure.Data;
using Salasel.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;


namespace Salasel.Infrastructure.Repositories
{
    public class MerchantInventoryRepository : Repository<MerchantInventory>, IMerchantInventoryRepository
    {
        public MerchantInventoryRepository(SalaselDbContext context) : base(context)
        {
        }

        public async Task<IEnumerable<MerchantInventory>> GetByMerchantIdAsync(int merchantId)
        {
            return await _dbSet.AsNoTracking().Where(i => i.MerchantID == merchantId).ToListAsync();
        }

        public async Task<IEnumerable<MerchantInventory>> GetBelowReorderThresholdAsync(int merchantId)
        {
            return await _dbSet
                .AsNoTracking()
                .Where(i => i.MerchantID == merchantId && i.CurrentQuantity <= i.ReorderThreshold)
                .ToListAsync();
        }

        public async Task<MerchantInventory?> GetBySkuAsync(int merchantId, string sku)
        {
            return await _dbSet.SingleOrDefaultAsync(i => i.MerchantID == merchantId && i.SKU == sku);
        }
    }

}
