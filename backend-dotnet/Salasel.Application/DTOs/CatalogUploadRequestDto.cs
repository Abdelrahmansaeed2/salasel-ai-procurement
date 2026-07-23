namespace Salasel.Application.DTOs;

public class CatalogUploadRequestDto
{
    public int SupplierID { get; set; }
    public string SKU { get; set; } = string.Empty;
    public string ProductName { get; set; } = string.Empty;
    public decimal UnitPrice { get; set; }
    public int StockAvailable { get; set; }
    public int DeliveryLeadTime_Days { get; set; }
    public string VectorEmbedding { get; set; } = string.Empty;
}
