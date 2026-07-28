using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Infrastructure.Data;
namespace Salasel.Infrastructure.Repositories;
public class SubOrderRepository : Repository<SubOrder>, ISubOrderRepository { public SubOrderRepository(SalaselDbContext context) : base(context) {} }
