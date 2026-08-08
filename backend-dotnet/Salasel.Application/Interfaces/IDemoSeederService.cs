namespace Salasel.Application.Interfaces;

public interface IDemoSeederService
{
    Task SeedMerchantDemoDataAsync(int userId, int merchantId);
}
