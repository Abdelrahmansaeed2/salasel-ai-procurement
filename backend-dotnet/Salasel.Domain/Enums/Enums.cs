namespace Salasel.Domain.Enums;

public enum ApprovalStatus : byte
{
    AI_Draft,
    Manually_Approved,
    AI_Rejected_Overstock,
    Fraud_Flagged
}

public enum FulfillmentStatus : byte
{
    Pending_Supplier,
    Shipped,
    Delivered
}

public enum UserRole : byte
{
    Merchant,
    Supplier,
    Admin
}

public enum RuleType : byte
{
    MaxOrderValue,
    MaxQuantityPerSKU
}