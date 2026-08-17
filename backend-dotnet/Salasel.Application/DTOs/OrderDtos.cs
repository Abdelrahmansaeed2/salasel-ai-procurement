namespace Salasel.Application.DTOs;

public class OrderDetailProductDto
{
    public int ProductId { get; set; }
    public string SupplierName { get; set; } = string.Empty;
    public string ProductName { get; set; } = string.Empty;
    public string RequestedQuantity { get; set; } = string.Empty;
    public string DetectedQuantity { get; set; } = string.Empty;
    public decimal UnitPrice { get; set; }
}

public class OrderDetailAiInsightsDto
{
    public string Language { get; set; } = string.Empty;
    public string ProcessingTime { get; set; } = string.Empty;
    public string Confidence { get; set; } = string.Empty;
}

public class OrderDetailDto
{
    public int Id { get; set; }
    public string OrderNumber { get; set; } = string.Empty;
    public double TotalAmount { get; set; }
    public double DeliveryFee { get; set; }
    public double Tax { get; set; }
    public DateTime OrderDate { get; set; }
    public string Status { get; set; } = string.Empty;
    public string Transcript { get; set; } = string.Empty;
    public OrderDetailAiInsightsDto? AiInsights { get; set; }
    public List<OrderDetailProductDto> Products { get; set; } = new();
}

public class SubmitSupplierRatingsDto
{
    public Dictionary<string, int> Ratings { get; set; } = new();
}
