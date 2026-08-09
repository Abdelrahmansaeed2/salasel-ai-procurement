namespace Salasel.Application.DTOs;

// GET /api/v1/orders/rfqs/kanban?supplierId=
public class KanbanResponseDto
{
    public List<KanbanColumnDto> Columns { get; set; } = new();
}

public class KanbanColumnDto
{
    public string Key { get; set; } = string.Empty;
    public string Label { get; set; } = string.Empty;
    public List<KanbanCardDto> Cards { get; set; } = new();
}

public class KanbanCardDto
{
    // "SUB-{subOrderId}", matching the spec's example card id.
    public string Id { get; set; } = string.Empty;
    public string Merchant { get; set; } = string.Empty;
    public string Total { get; set; } = "0.00";

    // Extra context beyond the minimal spec example — harmless to include,
    // drop from the client's view model if not needed.
    public string? ProductName { get; set; }
    public int Quantity { get; set; }
    public string Status { get; set; } = string.Empty;
}

// PUT /api/v1/orders/rfqs/{id}/bid  (id = SubOrderId)
public class SubmitBidDto
{
    public decimal Price { get; set; }
    public string? Notes { get; set; }
}

public class BidDto
{
    public int Id { get; set; }
    public int SubOrderId { get; set; }
    public int SupplierId { get; set; }
    public string SupplierName { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string? Notes { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime SubmittedAt { get; set; }
}

// PUT /api/v1/orders/rfqs/{id}/status  (id = SubOrderId, drag-drop)
public class RfqStatusUpdateDto
{
    public string Status { get; set; } = string.Empty;
}

// POST /api/v1/orders/rfqs — needed so a Bidding-status SubOrder can exist at
// all; nothing in the existing pipeline creates one otherwise (voice orders
// always auto-assign a single supplier immediately). See BiddingService.
public class CreateRfqDto
{
    public int MerchantId { get; set; }
    public int ProductId { get; set; }
    public int Quantity { get; set; }
    public string? Notes { get; set; }
}

public class SupplierOrderFeedDto
{
    public string Id { get; set; } = string.Empty;
    public string Merchant { get; set; } = string.Empty;
    public string Priority { get; set; } = string.Empty;
    public string PriorityLabel { get; set; } = string.Empty;
    public int Confidence { get; set; }
    public string ConfidenceColor { get; set; } = string.Empty;
    public string? Warning { get; set; }
    public string? AiNote { get; set; }
    public List<SupplierOrderFeedItemDto> Items { get; set; } = new();
    public string Total { get; set; } = "0.00";
    public string Currency { get; set; } = "ر.س";
}

public class SupplierOrderFeedItemDto
{
    public string Label { get; set; } = string.Empty;
    public string Price { get; set; } = string.Empty;
}
