using Salasel.Domain.Entities;

namespace Salasel.Domain.Interfaces
{
    public interface ISupplierCatalogRepository : IRepository<SupplierCatalog>
    {
        Task<IEnumerable<SupplierCatalog>> GetBySupplierIdAsync(int supplierId);
        Task<SupplierCatalog?> GetBySkuAsync(int supplierId, string sku);
        Task<IEnumerable<SupplierCatalog>> SearchByProductNameAsync(string searchTerm);
    }
}
