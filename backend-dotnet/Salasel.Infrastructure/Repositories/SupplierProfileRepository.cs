using Microsoft.EntityFrameworkCore;
using Salasel.Domain.Entities;
using Salasel.Domain.Interfaces;
using Salasel.Infrastructure.Data;


namespace Salasel.Infrastructure.Repositories
{
    public class SupplierProfileRepository : Repository<SupplierProfile>, ISupplierProfileRepository
    {
        public SupplierProfileRepository(SalaselDbContext context) : base(context)
        {
        }

        public async Task<IEnumerable<SupplierProfile>> GetActiveForRoutingAsync()
        {
            return await _dbSet.AsNoTracking().Where(s => s.IsActiveForRouting).ToListAsync();
        }

        public async Task<SupplierProfile?> GetWithCatalogAsync(int supplierId)
        {
            return await _dbSet
                .Include(s => s.SupplierCatalogs)
                .SingleOrDefaultAsync(s => s.SupplierID == supplierId);
        }
    }

}
