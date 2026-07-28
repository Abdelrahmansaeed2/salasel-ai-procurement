using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Infrastructure.Data;
namespace Salasel.Infrastructure.Repositories;
public class SupplierProfileRepository : Repository<SupplierProfile>, ISupplierProfileRepository { public SupplierProfileRepository(SalaselDbContext context) : base(context) {} }
