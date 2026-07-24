using Salasel.Domain.Entities;
using Salasel.Domain.Enums;
using Salasel.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Salasel.Domain.Interfaces;

namespace Salasel.Infrastructure.Repositories
{
    public class OrderSplitRepository : Repository<OrderSplit>, IOrderSplitRepository
    {
        public OrderSplitRepository(SalaselDbContext context) : base(context)
        {
        }

        public async Task<IEnumerable<OrderSplit>> GetByParentOrderIdAsync(int parentOrderId)
        {
            return await _dbSet.AsNoTracking().Where(s => s.ParentOrderID == parentOrderId).ToListAsync();
        }

        public async Task<IEnumerable<OrderSplit>> GetBySupplierIdAsync(int supplierId)
        {
            return await _dbSet.AsNoTracking().Where(s => s.SupplierID == supplierId).ToListAsync();
        }

        public async Task<IEnumerable<OrderSplit>> GetByFulfillmentStatusAsync(FulfillmentStatus status)
        {
            return await _dbSet.AsNoTracking().Where(s => s.FulfillmentStatus == status).ToListAsync();
        }
    }
}
