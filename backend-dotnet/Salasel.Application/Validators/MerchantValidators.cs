using FluentValidation;
using Salasel.Application.DTOs;

namespace Salasel.Application.Validators;

public class MerchantSetupDtoValidator : AbstractValidator<MerchantSetupDto>
{
    public MerchantSetupDtoValidator()
    {
        RuleFor(x => x.ShopName).NotEmpty().WithMessage("Shop name is required.").MaximumLength(200);
        RuleFor(x => x.OwnerName).NotEmpty().WithMessage("Owner name is required.").MaximumLength(150);
        RuleFor(x => x.CrNumber).NotEmpty().WithMessage("Commercial registration number is required.").MaximumLength(50);
        RuleFor(x => x.OwnerIdentityNumber).NotEmpty().WithMessage("Owner identity number is required.").MaximumLength(50);
        RuleFor(x => x.ContactPhone).NotEmpty().WithMessage("Contact phone is required.").MaximumLength(30);
        RuleFor(x => x.Category).NotEmpty().WithMessage("Category is required.").MaximumLength(100);
        RuleFor(x => x.StoreSize).NotEmpty().WithMessage("Store size is required.").MaximumLength(50);
        RuleFor(x => x.Governorate).NotEmpty().WithMessage("Governorate is required.").MaximumLength(100);
        RuleFor(x => x.BusinessCity).NotEmpty().WithMessage("Business city is required.").MaximumLength(100);
        RuleFor(x => x.Address).NotEmpty().WithMessage("Address is required.").MaximumLength(300);
        RuleFor(x => x.LocationLat).InclusiveBetween(-90, 90).WithMessage("Latitude must be between -90 and 90.");
        RuleFor(x => x.LocationLng).InclusiveBetween(-180, 180).WithMessage("Longitude must be between -180 and 180.");
    }
}

public class UpdateMerchantShopDtoValidator : AbstractValidator<UpdateMerchantShopDto>
{
    public UpdateMerchantShopDtoValidator()
    {
        RuleFor(x => x.ShopName).NotEmpty().WithMessage("Shop name is required.").MaximumLength(200);
        RuleFor(x => x.ContactPhone).NotEmpty().WithMessage("Contact phone is required.").MaximumLength(30);
        RuleFor(x => x.Category).NotEmpty().WithMessage("Category is required.").MaximumLength(100);
        RuleFor(x => x.StoreSize).NotEmpty().WithMessage("Store size is required.").MaximumLength(50);
        RuleFor(x => x.Governorate).NotEmpty().WithMessage("Governorate is required.").MaximumLength(100);
        RuleFor(x => x.BusinessCity).NotEmpty().WithMessage("Business city is required.").MaximumLength(100);
        RuleFor(x => x.Address).NotEmpty().WithMessage("Address is required.").MaximumLength(300);
        RuleFor(x => x.LocationLat).InclusiveBetween(-90, 90).WithMessage("Latitude must be between -90 and 90.");
        RuleFor(x => x.LocationLng).InclusiveBetween(-180, 180).WithMessage("Longitude must be between -180 and 180.");
    }
}

public class UpdateMerchantMeProfileDtoValidator : AbstractValidator<UpdateMerchantMeProfileDto>
{
    public UpdateMerchantMeProfileDtoValidator()
    {
        RuleFor(x => x.FullName)
            .NotEmpty().WithMessage("Full Name is required.")
            .MinimumLength(3).WithMessage("Full Name must be at least 3 characters.");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email is required.")
            .EmailAddress().WithMessage("A valid email address is required.");
    }
}
