using Salasel.Application.Interfaces;
using Salasel.Domain.Entities;
using Salasel.Infrastructure.Data;
namespace Salasel.Infrastructure.Repositories;
public class VoiceProcurementLogRepository : Repository<VoiceProcurementLog>, IVoiceProcurementLogRepository { public VoiceProcurementLogRepository(SalaselDbContext context) : base(context) {} }
