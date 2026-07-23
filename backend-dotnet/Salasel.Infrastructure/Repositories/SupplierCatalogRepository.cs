using Salasel.Domain.Entities;
using Salasel.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Salasel.Domain.Interfaces;

namespace Salasel.Infrastructure.Repositories
{
    public class SupplierCatalogRepository : Repository<SupplierCatalog>, ISupplierCatalogRepository
    {
        public SupplierCatalogRepository(SalaselDbContext context) : base(context)
        {
        }

        public async Task<IEnumerable<SupplierCatalog>> GetBySupplierIdAsync(int supplierId)
        {
            return await _dbSet.AsNoTracking().Where(c => c.SupplierID == supplierId).ToListAsync();
        }

        public async Task<SupplierCatalog?> GetBySkuAsync(int supplierId, string sku)
        {
            return await _dbSet.SingleOrDefaultAsync(c => c.SupplierID == supplierId && c.SKU == sku);
        }

        public async Task<IEnumerable<SupplierCatalog>> SearchByProductNameAsync(string searchTerm)
        {
            return await _dbSet
                .AsNoTracking()
                .Where(c => c.ProductName.Contains(searchTerm))
                .ToListAsync();
        }
    }
}
