using Salasel.Domain.Entities;
using Salasel.Domain.Interfaces;
using Salasel.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Salasel.Infrastructure.Repositories
{
    public class UserRepository : Repository<User>, IUserRepository
    {
        public UserRepository(SalaselDbContext context) : base(context)
        {
        }

        public async Task<User?> GetByEmailAsync(string email)
        {
            var normalized = email.Trim().ToUpperInvariant();
            return await _dbSet.SingleOrDefaultAsync(u => u.Email.ToUpper() == normalized);
        }

        public async Task<bool> EmailExistsAsync(string email)
        {
            var normalized = email.Trim().ToUpperInvariant();
            return await _dbSet.AnyAsync(u => u.Email.ToUpper() == normalized);
        }

        public async Task<User?> GetWithProfileAsync(int userId)
        {
            return await _dbSet
                .Include(u => u.MerchantsProfile)
                .Include(u => u.SupplierProfile)
                .SingleOrDefaultAsync(u => u.UserID == userId);
        }
    }
}