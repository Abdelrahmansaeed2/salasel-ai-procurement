namespace Salasel.Application.DTOs;

public class OrderExecutionRequestDto
{
    public int MerchantID { get; set; }
    public int? VoiceLogID { get; set; }
    public decimal TotalOrderCost { get; set; }
    public List<OrderSplitDto> Splits { get; set; } = new List<OrderSplitDto>();
}

public class OrderSplitDto
{
    public int SupplierID { get; set; }
    public string SKU { get; set; } = string.Empty;
    public int QuantityOrdered { get; set; }
    public decimal SubTotalCost { get; set; }
}
