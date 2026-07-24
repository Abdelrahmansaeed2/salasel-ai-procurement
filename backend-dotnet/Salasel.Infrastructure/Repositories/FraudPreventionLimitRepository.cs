using Salasel.Domain.Entities;
using Salasel.Domain.Enums;
using Salasel.Infrastructure.Data;
using Salasel.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Salasel.Infrastructure.Repositories
{
    public class FraudPreventionLimitRepository : Repository<FraudPreventionLimit>, IFraudPreventionLimitRepository
    {
        public FraudPreventionLimitRepository(SalaselDbContext context) : base(context)
        {
        }

        public async Task<FraudPreventionLimit?> GetActiveByTypeAsync(RuleType ruleType)
        {
            return await _dbSet.SingleOrDefaultAsync(r => r.RuleType == ruleType && r.IsActive);
        }

        public async Task<IEnumerable<FraudPreventionLimit>> GetActiveRulesAsync()
        {
            return await _dbSet.AsNoTracking().Where(r => r.IsActive).ToListAsync();
        }
    }
}
