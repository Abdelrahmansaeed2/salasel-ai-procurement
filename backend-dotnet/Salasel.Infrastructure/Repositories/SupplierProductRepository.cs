using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Infrastructure.Data;
namespace Salasel.Infrastructure.Repositories;
public class SupplierProductRepository : Repository<SupplierProduct>, ISupplierProductRepository { public SupplierProductRepository(SalaselDbContext context) : base(context) {} }
