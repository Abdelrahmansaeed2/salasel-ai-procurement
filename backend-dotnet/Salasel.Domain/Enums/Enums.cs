namespace Salasel.Domain.Enums;

public enum UserRole : byte
{
    Merchant,
    Supplier,
    Admin
}

public enum ApprovalStatus : byte
{
    AI_Draft,
    Pending_Approval,
    Manually_Approved,
    Rejected
}

public enum FulfillmentStatus : byte
{
    Pending_Supplier,
    Accepted,
    Shipped,
    Delivered,
    Cancelled
}

public enum OrderSource : byte
{
    Voice,       // came from voice recording
    TextInput,   // merchant typed the order
    Manual,      // created manually from the app UI
    AI_Auto      // triggered automatically by AI when stock is low
}
