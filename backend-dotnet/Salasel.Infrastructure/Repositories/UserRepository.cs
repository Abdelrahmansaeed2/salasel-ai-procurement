using Microsoft.EntityFrameworkCore;
using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Infrastructure.Data;
namespace Salasel.Infrastructure.Repositories;
public class UserRepository : Repository<User>, IUserRepository { public UserRepository(SalaselDbContext context) : base(context) {} public async Task<bool> EmailExistsAsync(string email) => await _context.Users.AnyAsync(u => u.Email == email); public async Task<User?> GetByEmailAsync(string email) => await _context.Users.FirstOrDefaultAsync(u => u.Email == email); }
