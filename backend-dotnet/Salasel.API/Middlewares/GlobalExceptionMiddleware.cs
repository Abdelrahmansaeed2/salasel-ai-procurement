using System.Net;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;

namespace Salasel.API.Middlewares;

public class GlobalExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<GlobalExceptionMiddleware> _logger;

    public GlobalExceptionMiddleware(RequestDelegate next, ILogger<GlobalExceptionMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "An unhandled exception occurred.");
            await HandleExceptionAsync(context, ex);
        }
    }

    private static Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        context.Response.ContentType = "application/json";
        
        var problemDetails = new ProblemDetails
        {
            Title = "An error occurred while processing your request.",
            Detail = exception.Message,
            Status = (int)HttpStatusCode.InternalServerError,
            Instance = context.Request.Path
        };

        // Standardize errors (could add custom exception types like NotFoundException later)
        if (exception.Message.Contains("Invalid email") || exception.Message.Contains("exists") || exception.Message.Contains("deactivated"))
        {
            problemDetails.Status = (int)HttpStatusCode.BadRequest;
            problemDetails.Title = "Bad Request";
        }
        else if (exception.Message.Contains("Unauthorized"))
        {
            problemDetails.Status = (int)HttpStatusCode.Unauthorized;
            problemDetails.Title = "Unauthorized";
        }

        context.Response.StatusCode = problemDetails.Status.Value;

        var result = JsonSerializer.Serialize(problemDetails);
        return context.Response.WriteAsync(result);
    }
}
