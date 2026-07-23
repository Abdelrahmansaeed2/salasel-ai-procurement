using Salasel.Domain.Entities;
using Salasel.Domain.Enums;

namespace Salasel.Domain.Interfaces
{
    public interface IFraudPreventionLimitRepository : IRepository<FraudPreventionLimit>
    {
        Task<FraudPreventionLimit?> GetActiveByTypeAsync(RuleType ruleType);
        Task<IEnumerable<FraudPreventionLimit>> GetActiveRulesAsync();
    }
}
