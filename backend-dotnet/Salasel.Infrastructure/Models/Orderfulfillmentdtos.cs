using System.ComponentModel.DataAnnotations;
using Salasel.Domain.Enums;

namespace Salasel.Infrastructure.Models;

// GET /api/voice-orders/{id}/tracking
public class TrackingDto
{
    public int OrderId { get; set; }
    public string CurrentStatus { get; set; } = string.Empty;
    public List<TrackingStepDto> Timeline { get; set; } = new();
}

public class TrackingStepDto
{
    public string Step { get; set; } = string.Empty;
    public bool Completed { get; set; }
    public DateTime? Timestamp { get; set; }
}

// POST /api/voice-orders/{id}/assign-driver
public class AssignDriverDto
{
    [Required, MinLength(1)]
    public string DriverName { get; set; } = string.Empty;

    public string? DriverPhone { get; set; }
}

// POST /api/voice-orders/{id}/payment — checkout
public class MakePaymentDto
{
    [Required]
    public PaymentMethod PaymentMethod { get; set; }
}

// GET /api/voice-orders/{id}/payment-status
public class PaymentStatusDto
{
    public int OrderId { get; set; }
    public string? PaymentMethod { get; set; }
    public string PaymentStatus { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public DateTime? PaidAt { get; set; }
    public string? PaymentReference { get; set; }
}