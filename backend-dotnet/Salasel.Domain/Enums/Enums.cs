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
    Rejected,
    Completed   // full lifecycle finished: fulfillment receipt confirmed by merchant
}

public enum FulfillmentStatus : byte
{
    Pending_Supplier,
    Bidding,     // open for competitive bids - no supplier assigned yet (see Bid entity)
    Accepted,
    Shipped,
    Delivered,
    ReceiptConfirmed,
    Cancelled
}

public enum BidStatus : byte
{
    Submitted,
    Accepted,
    Rejected
}

public enum OrderSource : byte
{
    Voice,       // came from voice recording
    TextInput,   // merchant typed the order
    Manual,      // created manually from the app UI
    AI_Auto      // triggered automatically by AI when stock is low
}

public enum MerchantVerificationStatus : byte
{
    NotSubmitted,
    UnderReview,
    Approved,
    Rejected
}

public enum MerchantDocumentType : byte
{
    CommercialRegistration,
    OwnerIdentity
}

public enum PaymentMethod : byte
{
    CashOnDelivery,
    BankTransfer,
    CreditCard,
    Stripe,
    PayTabs
}

public enum PaymentStatus : byte
{
    Unpaid,
    Pending,   // payment method chosen, awaiting settlement (e.g. cash on delivery)
    Paid,
    Failed,
    RefundRequested,
    Refunded
}

public enum KnowledgeDocumentStatus : byte
{
    Processing,
    Indexed,
    Failed
}