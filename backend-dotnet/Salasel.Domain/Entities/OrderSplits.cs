using Salasel.Domain.Enums;

namespace Salasel.Domain.Entities;

public class OrderSplits
{
    public int SplitID { get; set; }
    
    public int ParentOrderID { get; set; }
    public OrderTransactions ParentOrder { get; set; } = null!;

    public int SupplierID { get; set; }
    public SupplierProfile Supplier { get; set; } = null!;

    public string SKU { get; set; } = string.Empty;
    public int QuantityOrdered { get; set; }
    public decimal SubTotalCost { get; set; }
    public FulfillmentStatus FulfillmentStatus { get; set; }
}
