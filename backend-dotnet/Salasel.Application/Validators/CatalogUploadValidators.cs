using FluentValidation;
using Salasel.Application.DTOs;

namespace Salasel.Application.Validators;

public class CatalogUploadRequestDtoValidator : AbstractValidator<CatalogUploadRequestDto>
{
    public CatalogUploadRequestDtoValidator()
    {
        RuleFor(x => x.SupplierID)
            .GreaterThan(0).WithMessage("SupplierID must be a valid positive integer.");

        RuleFor(x => x.SKU)
            .NotEmpty().WithMessage("SKU is required.");

        RuleFor(x => x.ProductName)
            .NotEmpty().WithMessage("Product Name is required.");

        RuleFor(x => x.UnitPrice)
            .GreaterThanOrEqualTo(0).WithMessage("Unit Price must be non-negative.");

        RuleFor(x => x.StockAvailable)
            .GreaterThanOrEqualTo(0).WithMessage("Stock Available must be non-negative.");

        RuleFor(x => x.DeliveryLeadTime_Days)
            .GreaterThanOrEqualTo(0).WithMessage("Delivery Lead Time must be non-negative.");
            
        RuleFor(x => x.VectorEmbedding)
            .NotEmpty().WithMessage("Vector Embedding JSON is required.");
    }
}
