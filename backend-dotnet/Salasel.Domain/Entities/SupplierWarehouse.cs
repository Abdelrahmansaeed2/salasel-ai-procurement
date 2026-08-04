namespace Salasel.Domain.Entities;

public class SupplierWarehouse
{
    public int Id { get; set; }

    public int SupplierId { get; set; }
    public SupplierProfile Supplier { get; set; } = null!;

    public string WarehouseName { get; set; } = string.Empty;
    public string Capacity { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public decimal Lat { get; set; }
    public decimal Lng { get; set; }
}