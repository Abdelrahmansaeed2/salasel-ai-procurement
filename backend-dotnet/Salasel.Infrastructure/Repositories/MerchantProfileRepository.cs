using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Infrastructure.Data;
namespace Salasel.Infrastructure.Repositories;
public class MerchantProfileRepository : Repository<MerchantsProfile>, IMerchantProfileRepository { public MerchantProfileRepository(SalaselDbContext context) : base(context) {} }
