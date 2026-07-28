using Salasel.Domain.Interfaces;
using Salasel.Domain.Entities; namespace Salasel.Application.Interfaces; public interface IUserRepository : IRepository<User> { Task<bool> EmailExistsAsync(string email); Task<User?> GetByEmailAsync(string email); }
