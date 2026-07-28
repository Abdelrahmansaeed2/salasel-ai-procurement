using System.Diagnostics;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace Salasel.API.Middlewares;

/// <summary>
/// A lightweight Observability middleware designed to track API latency 
/// and prepare traces for Langfuse AI integration in the future.
/// </summary>
public class LangfuseMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<LangfuseMiddleware> _logger;

    public LangfuseMiddleware(RequestDelegate next, ILogger<LangfuseMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var stopwatch = Stopwatch.StartNew();
        var traceId = context.TraceIdentifier;

        try
        {
            // Proceed to next middleware
            await _next(context);
            stopwatch.Stop();

            _logger.LogInformation(
                "LangfuseTrace [SUCCESS] - TraceId: {TraceId}, Path: {Path}, Method: {Method}, Status: {Status}, Latency: {Latency}ms",
                traceId, context.Request.Path, context.Request.Method, context.Response.StatusCode, stopwatch.ElapsedMilliseconds);
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            
            _logger.LogError(
                ex,
                "LangfuseTrace [ERROR] - TraceId: {TraceId}, Path: {Path}, Method: {Method}, Latency: {Latency}ms - Exception: {ExceptionMessage}",
                traceId, context.Request.Path, context.Request.Method, stopwatch.ElapsedMilliseconds, ex.Message);
                
            throw; // Rethrow to be caught by GlobalExceptionMiddleware
        }
    }
}
