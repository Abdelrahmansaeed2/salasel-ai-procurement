using Salasel.Domain.Enums;

namespace Salasel.Domain.Entities;

public class FraudPreventionLimits
{
    public int RuleID { get; set; }
    public RuleType RuleType { get; set; }
    public decimal HardLimitValue { get; set; }
    public bool IsActive { get; set; }
}
