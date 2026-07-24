using Salasel.Domain.Entities;
using Salasel.Domain.Enums;
using Salasel.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Salasel.Domain.Interfaces;


namespace Salasel.Infrastructure.Repositories
{
    public class OrderTransactionRepository : Repository<OrderTransaction>, IOrderTransactionRepository
    {
        public OrderTransactionRepository(SalaselDbContext context) : base(context)
        {
        }

        public async Task<IEnumerable<OrderTransaction>> GetByMerchantIdAsync(int merchantId)
        {
            return await _dbSet
                .AsNoTracking()
                .Where(o => o.MerchantID == merchantId)
                .OrderByDescending(o => o.CreatedAt)
                .ToListAsync();
        }

        public async Task<IEnumerable<OrderTransaction>> GetByStatusAsync(ApprovalStatus status)
        {
            return await _dbSet
                .AsNoTracking()
                .Where(o => o.ApprovalStatus == status)
                .OrderByDescending(o => o.CreatedAt)
                .ToListAsync();
        }

        public async Task<OrderTransaction?> GetWithSplitsAsync(int orderId)
        {
            return await _dbSet
                .Include(o => o.OrderSplits)
                .SingleOrDefaultAsync(o => o.OrderID == orderId);
        }
    }
}
