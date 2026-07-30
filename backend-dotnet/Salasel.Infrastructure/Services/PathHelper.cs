namespace Salasel.Infrastructure.Services;

public static class PathHelpers
{
    public static string ToAbsolute(string relativePath, string webRootPath)
    {
        var normalized = relativePath.Replace('/', Path.DirectorySeparatorChar);
        return Path.Combine(webRootPath, normalized);
    }

    public static string ToRelative(string absolutePath, string webRootPath)
    {
        var relative = Path.GetRelativePath(webRootPath, absolutePath);
        return relative.Replace(Path.DirectorySeparatorChar, '/');
    }
}
