using FluentValidation;
using Salasel.Application.DTOs;

namespace Salasel.Application.Validators;

public class OrderExecutionRequestDtoValidator : AbstractValidator<OrderExecutionRequestDto>
{
    public OrderExecutionRequestDtoValidator()
    {
        RuleFor(x => x.MerchantID)
            .GreaterThan(0).WithMessage("MerchantID must be a valid positive integer.");

        RuleFor(x => x.TotalOrderCost)
            .GreaterThanOrEqualTo(0).WithMessage("Total Order Cost must be non-negative.");

        RuleFor(x => x.Splits)
            .NotEmpty().WithMessage("Order must contain at least one split.");

        RuleForEach(x => x.Splits).SetValidator(new OrderSplitDtoValidator());
    }
}

public class OrderSplitDtoValidator : AbstractValidator<OrderSplitDto>
{
    public OrderSplitDtoValidator()
    {
        RuleFor(x => x.SupplierID)
            .GreaterThan(0).WithMessage("SupplierID must be a valid positive integer.");

        RuleFor(x => x.SKU)
            .NotEmpty().WithMessage("SKU is required.");

        RuleFor(x => x.QuantityOrdered)
            .GreaterThan(0).WithMessage("Quantity ordered must be greater than 0.");

        RuleFor(x => x.SubTotalCost)
            .GreaterThanOrEqualTo(0).WithMessage("SubTotal Cost must be non-negative.");
    }
}
