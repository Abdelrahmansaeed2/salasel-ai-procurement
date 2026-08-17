namespace Salasel.Application.DTOs;

public class ManualOrderRequestDto
{
    public List<ManualOrderItemDto> Items { get; set; } = new();
}

public class ManualOrderItemDto
{
    public int ProductId { get; set; }
    public int Quantity { get; set; }
}
