using Salasel.Domain.Entities;
using Salasel.Infrastructure.Data;
using Salasel.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Salasel.Infrastructure.Repositories
{
    public class VoiceProcurementLogRepository : Repository<VoiceProcurementLog>, IVoiceProcurementLogRepository
    {
        public VoiceProcurementLogRepository(SalaselDbContext context) : base(context)
        {
        }

        public async Task<IEnumerable<VoiceProcurementLog>> GetByMerchantIdAsync(int merchantId)
        {
            return await _dbSet
                .AsNoTracking()
                .Where(v => v.MerchantID == merchantId)
                .OrderByDescending(v => v.ProcessedAt)
                .ToListAsync();
        }

        public async Task<VoiceProcurementLog?> GetWithOrderTransactionAsync(int logId)
        {
            return await _dbSet
                .Include(v => v.OrderTransactions)
                .SingleOrDefaultAsync(v => v.LogID == logId);
        }
    }
}
