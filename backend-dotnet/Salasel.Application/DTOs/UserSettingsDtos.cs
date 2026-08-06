namespace Salasel.Application.DTOs;

public class NotificationSettingsDto
{
    public bool PushEnabled { get; set; } = true;
    public bool EmailEnabled { get; set; } = true;
    public bool OrderUpdates { get; set; } = true;
    public bool BiddingUpdates { get; set; } = true;
    public bool InventoryAlerts { get; set; } = true;
    public bool Marketing { get; set; } = false;
}

public class UpdateLanguageDto
{
    public string Language { get; set; } = "en";
}
