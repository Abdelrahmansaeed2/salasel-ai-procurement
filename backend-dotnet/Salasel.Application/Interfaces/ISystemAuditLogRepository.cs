using Salasel.Domain.Entities;

namespace Salasel.Domain.Interfaces
{
    public interface ISystemAuditLogRepository : IRepository<SystemAuditLog>
    {
        Task<IEnumerable<SystemAuditLog>> GetByAdminIdAsync(int adminUserId);
        Task<IEnumerable<SystemAuditLog>> GetByTargetTableAsync(string targetTable);
    }
}
