using Salasel.Application.DTOs;

namespace Salasel.Application.Interfaces;

public interface IProcurementService
{
    Task<int> LogVoiceProcurementAsync(VoiceProcurementRequestDto request);
}

public interface IOrderExecutionService
{
    Task<int> ExecuteOrderAsync(OrderExecutionRequestDto request);
}

public interface IInventoryService
{
    Task<object> GetInventoryStatusAsync(int merchantId);
}

public interface ICatalogService
{
    Task<int> UploadCatalogAsync(CatalogUploadRequestDto request);
}
