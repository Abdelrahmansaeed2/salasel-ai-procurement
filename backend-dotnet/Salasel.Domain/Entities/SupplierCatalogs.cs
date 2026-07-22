namespace Salasel.Domain.Entities;

public class SupplierCatalogs
{
    public int CatalogID { get; set; }
    
    public int SupplierID { get; set; }
    public SupplierProfile Supplier { get; set; } = null!;

    public string SKU { get; set; } = string.Empty;
    public string ProductName { get; set; } = string.Empty;
    public decimal UnitPrice { get; set; }
    public int StockAvailable { get; set; }
    public int DeliveryLeadTime_Days { get; set; }
    
    // Storing pgvector embeddings as a string (JSON array) since SQL Server doesn't natively support pgvector
    public string VectorEmbedding { get; set; } = string.Empty;
    
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
