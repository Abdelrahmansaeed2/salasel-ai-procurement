using System.Text.Json;
using Microsoft.Extensions.Logging;
using Salasel.Infrastructure.Models;

namespace Salasel.Infrastructure.Services;

public interface IFakeAIService
{
    Task<AiOrderResult> ProcessVoiceAsync(string filePath, int merchantId, CancellationToken ct = default);
}

public class FakeAIService : IFakeAIService
{
    private readonly ILogger<FakeAIService> _logger;
    private static readonly Random _rng = new();

    private static readonly string[][] ProductSets =
    {
        new[] { "Pepsi", "Milk", "Bread", "Eggs" },
        new[] { "Coca-Cola", "Cheese", "Butter", "Yogurt" },
        new[] { "Water Bottles", "Rice", "Sugar", "Tea" }
    };

    public FakeAIService(ILogger<FakeAIService> logger)
    {
        _logger = logger;
    }

    public async Task<AiOrderResult> ProcessVoiceAsync(string filePath, int merchantId, CancellationToken ct = default)
    {
        _logger.LogInformation(
            "FakeAI: starting speech-to-text + extraction for {File} (merchant {MerchantId})",
            filePath, merchantId);

        var delayMs = 2000 + _rng.Next(3000);
        await Task.Delay(delayMs, ct);

        var products = ProductSets[_rng.Next(ProductSets.Length)];
        var itemCount = 2 + _rng.Next(3);

        var items = new List<AiOrderItem>();
        for (int i = 0; i < itemCount && i < products.Length; i++)
        {
            items.Add(new AiOrderItem
            {
                ProductName = products[i],
                Quantity = 5 + _rng.Next(30),
                Price = Math.Round((decimal)(0.5 + _rng.NextDouble() * 4.5), 2)
            });
        }

        var result = new AiOrderResult
        {
            MerchantId = merchantId,
            Items = items
        };

        _logger.LogInformation("FakeAI: completed. Mock result: {Json}", JsonSerializer.Serialize(result));
        return result;
    }
}
