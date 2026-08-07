using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Infrastructure.Data;
namespace Salasel.Infrastructure.Repositories;
public class MasterOrderRepository : Repository<MasterOrder>, IMasterOrderRepository { public MasterOrderRepository(SalaselDbContext context) : base(context) {} }
