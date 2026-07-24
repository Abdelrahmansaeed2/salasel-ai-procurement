using Microsoft.EntityFrameworkCore;
using Salasel.Domain.Entities;
using Salasel.Domain.Interfaces;
using Salasel.Infrastructure.Data;


namespace Salasel.Infrastructure.Repositories
{
    public class SystemAuditLogRepository : Repository<SystemAuditLog>, ISystemAuditLogRepository
    {
        public SystemAuditLogRepository(SalaselDbContext context) : base(context)
        {
        }

        public async Task<IEnumerable<SystemAuditLog>> GetByAdminIdAsync(int adminUserId)
        {
            return await _dbSet
                .AsNoTracking()
                .Where(a => a.AdminUserID == adminUserId)
                .OrderByDescending(a => a.Timestamp)
                .ToListAsync();
        }

        public async Task<IEnumerable<SystemAuditLog>> GetByTargetTableAsync(string targetTable)
        {
            return await _dbSet
                .AsNoTracking()
                .Where(a => a.TargetTable == targetTable)
                .OrderByDescending(a => a.Timestamp)
                .ToListAsync();
        }
    }

}
