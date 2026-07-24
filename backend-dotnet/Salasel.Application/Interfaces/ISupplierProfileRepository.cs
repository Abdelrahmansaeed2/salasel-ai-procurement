using Salasel.Domain.Entities;

namespace Salasel.Domain.Interfaces
{
    public interface ISupplierProfileRepository : IRepository<SupplierProfile>
    {
        Task<IEnumerable<SupplierProfile>> GetActiveForRoutingAsync();
        Task<SupplierProfile?> GetWithCatalogAsync(int supplierId);
    }
}
