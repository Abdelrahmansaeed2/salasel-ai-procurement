using FluentValidation;
using Salasel.Application.DTOs;

namespace Salasel.Application.Validators;

public class VoiceProcurementRequestDtoValidator : AbstractValidator<VoiceProcurementRequestDto>
{
    public VoiceProcurementRequestDtoValidator()
    {
        RuleFor(x => x.MerchantID)
            .GreaterThan(0).WithMessage("MerchantID must be a valid positive integer.");

        RuleFor(x => x.RawAudioURL)
            .NotEmpty().WithMessage("RawAudioURL is required.")
            .Must(uri => Uri.TryCreate(uri, UriKind.Absolute, out _)).WithMessage("RawAudioURL must be a valid URL.");

        RuleFor(x => x.TranscribedAmiyaText)
            .NotEmpty().WithMessage("Transcribed text is required.");

        RuleFor(x => x.LLMParsedJSON)
            .NotEmpty().WithMessage("LLM Parsed JSON is required.");

        RuleFor(x => x.NLPConfidenceScore)
            .InclusiveBetween(0m, 1m).WithMessage("NLP Confidence Score must be between 0.0 and 1.0.");
    }
}
