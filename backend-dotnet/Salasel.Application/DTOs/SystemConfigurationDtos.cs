namespace Salasel.Application.DTOs;

public class SystemConfigurationDto
{
    public int Id { get; set; }
    public string Key { get; set; } = string.Empty;
    public string Value { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public DateTime LastUpdated { get; set; }
}

public class UpdateSystemConfigurationDto
{
    public string Value { get; set; } = string.Empty;
}
