using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Infrastructure.Data;
namespace Salasel.Infrastructure.Repositories;
public class MerchantInventoryRepository : Repository<MerchantInventory>, IMerchantInventoryRepository { public MerchantInventoryRepository(SalaselDbContext context) : base(context) {} }
