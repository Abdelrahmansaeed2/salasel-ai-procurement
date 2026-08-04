using FluentValidation;
using Salasel.Application.DTOs;

namespace Salasel.Application.Validators;

public class WarehouseDtoValidator : AbstractValidator<WarehouseDto>
{
    public WarehouseDtoValidator()
    {
        RuleFor(x => x.City).NotEmpty().WithMessage("Warehouse city is required.");
        RuleFor(x => x.Lat).InclusiveBetween(-90, 90).WithMessage("Latitude must be between -90 and 90.");
        RuleFor(x => x.Lng).InclusiveBetween(-180, 180).WithMessage("Longitude must be between -180 and 180.");
    }
}

public class SupplierSetupDtoValidator : AbstractValidator<SupplierSetupDto>
{
    public SupplierSetupDtoValidator()
    {
        RuleFor(x => x.CompanyName)
            .NotEmpty().WithMessage("Company name is required.")
            .MaximumLength(200);

        RuleFor(x => x.CrNumber)
            .NotEmpty().WithMessage("Commercial registration number is required.")
            .Matches(@"^\d{10}$").WithMessage("CR number must be 10 digits.");

        RuleFor(x => x.TaxNumber)
            .NotEmpty().WithMessage("Tax number is required.")
            .Matches(@"^\d{15}$").WithMessage("Tax number must be 15 digits.");

        RuleFor(x => x.BankName)
            .NotEmpty().WithMessage("Bank name is required.");

        RuleFor(x => x.Iban)
            .NotEmpty().WithMessage("IBAN is required.")
            .Matches(@"^SA\d{22}$").WithMessage("IBAN must be a valid Saudi IBAN (SA + 22 digits).");

        RuleFor(x => x.Warehouses)
            .NotEmpty().WithMessage("At least one warehouse is required.");

        RuleForEach(x => x.Warehouses).SetValidator(new WarehouseDtoValidator());
    }
}

public class UpdateSupplierProfileDtoValidator : AbstractValidator<UpdateSupplierProfileDto>
{
    public UpdateSupplierProfileDtoValidator()
    {
        RuleFor(x => x.CompanyName).NotEmpty().MaximumLength(200);
        RuleFor(x => x.Iban)
            .Matches(@"^SA\d{22}$").WithMessage("IBAN must be a valid Saudi IBAN (SA + 22 digits).")
            .When(x => !string.IsNullOrWhiteSpace(x.Iban));
    }
}

public class CreateSupplierProductDtoValidator : AbstractValidator<CreateSupplierProductDto>
{
    public CreateSupplierProductDtoValidator()
    {
        RuleFor(x => x)
            .Must(x => x.ProductId.HasValue || !string.IsNullOrWhiteSpace(x.NewProductName))
            .WithMessage("Provide either an existing ProductId or NewProductName to create one.");

        When(x => !x.ProductId.HasValue, () =>
        {
            RuleFor(x => x.NewProductSKU).NotEmpty().WithMessage("SKU is required for a new product.");
            RuleFor(x => x.NewProductUnit).NotEmpty().WithMessage("Unit is required for a new product.");
            RuleFor(x => x.NewProductCategoryId).NotNull().WithMessage("CategoryId is required for a new product.");
        });

        RuleFor(x => x.UnitPrice).GreaterThanOrEqualTo(0);
        RuleFor(x => x.AvailableQty).GreaterThanOrEqualTo(0);
        RuleFor(x => x.MinOrderQty).GreaterThanOrEqualTo(1);
        RuleFor(x => x.LeadTimeDays).GreaterThanOrEqualTo(0);
    }
}

public class UpdateSupplierProductDtoValidator : AbstractValidator<UpdateSupplierProductDto>
{
    public UpdateSupplierProductDtoValidator()
    {
        RuleFor(x => x.UnitPrice).GreaterThanOrEqualTo(0);
        RuleFor(x => x.AvailableQty).GreaterThanOrEqualTo(0);
        RuleFor(x => x.MinOrderQty).GreaterThanOrEqualTo(1);
        RuleFor(x => x.LeadTimeDays).GreaterThanOrEqualTo(0);
    }
}