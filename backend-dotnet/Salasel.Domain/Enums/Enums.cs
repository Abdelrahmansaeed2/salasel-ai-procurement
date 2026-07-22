namespace Salasel.Domain.Enums;

public enum ApprovalStatus
{
    AI_Draft,
    Manually_Approved,
    AI_Rejected,
    Overstock,
    Fraud_Flagged
}

public enum FulfillmentStatus
{
    Pending_Supplier,
    Shipped,
    Delivered
}

public enum UserRole
{
    Merchant,
    Supplier,
    Admin
}

public enum RuleType
{
    MaxOrderValue,
    MaxQuantityPerSKU
}
