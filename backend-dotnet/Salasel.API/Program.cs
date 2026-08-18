using FluentValidation;
using FluentValidation.AspNetCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Salasel.API.Middlewares;
using Salasel.Application.Interfaces;
using Salasel.Application.Services;
using Salasel.Application.Validators;
using Salasel.Domain.Interfaces;
using Salasel.Infrastructure.Data;
using Salasel.Infrastructure.Hubs;
using Salasel.Infrastructure.Repositories;
using Salasel.Infrastructure.Services;
using Serilog;
using System.Security.Claims;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);

// Configure Serilog
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft", Serilog.Events.LogEventLevel.Warning)
    .Enrich.FromLogContext()
    .WriteTo.Console()
    .WriteTo.File("logs/log-.txt", rollingInterval: RollingInterval.Day)
    .WriteTo.Seq(builder.Configuration["Seq:Url"] ?? "https://seq.otlob-egy.online")
    .CreateLogger();

builder.Host.UseSerilog();

var firebaseKeyPath = Path.Combine(builder.Environment.ContentRootPath, "firebase-admin.json");
if (File.Exists(firebaseKeyPath))
{
    FirebaseAdmin.FirebaseApp.Create(new FirebaseAdmin.AppOptions
    {
        Credential = Google.Apis.Auth.OAuth2.GoogleCredential.FromFile(firebaseKeyPath)
    });
}

// Add DbContext
builder.Services.AddDbContext<SalaselDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        sqlServerOptionsAction: sqlOptions =>
        {
            sqlOptions.EnableRetryOnFailure(
                maxRetryCount: 5,
                maxRetryDelay: TimeSpan.FromSeconds(30),
                errorNumbersToAdd: null);
        }));

// Add Authentication
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidAudience = builder.Configuration["Jwt:Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!))
    };

    // Enforces logout / change-password revocation: a token is only valid
    // if the "tokenVersion" claim it was issued with still matches the
    // user's current TokenVersion in the database.
    options.Events = new JwtBearerEvents
    {
        OnTokenValidated = async context =>
        {
            var userIdStr = context.Principal?.FindFirstValue(ClaimTypes.NameIdentifier);
            var tokenVersionStr = context.Principal?.FindFirstValue(Salasel.Application.Services.AuthService.TokenVersionClaimType);

            if (!int.TryParse(userIdStr, out var userId) || !int.TryParse(tokenVersionStr, out var tokenVersion))
            {
                context.Fail("Invalid token claims.");
                return;
            }

            var userRepository = context.HttpContext.RequestServices.GetRequiredService<IUserRepository>();
            var user = await userRepository.GetByIdAsync(userId);

            if (user == null || !user.IsActive || user.TokenVersion != tokenVersion)
            {
                context.Fail("Token has been revoked.");
            }
        }
    };
});

// Add Repositories
builder.Services.AddScoped(typeof(IRepository<>), typeof(Repository<>));
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IMerchantProfileRepository, MerchantProfileRepository>();
builder.Services.AddScoped<ISupplierProfileRepository, SupplierProfileRepository>();
builder.Services.AddScoped<IMasterOrderRepository, MasterOrderRepository>();
builder.Services.AddScoped<ISubOrderRepository, SubOrderRepository>();
builder.Services.AddScoped<ISupplierProductRepository, SupplierProductRepository>();
builder.Services.AddScoped<IMerchantInventoryRepository, MerchantInventoryRepository>();
builder.Services.AddScoped<IVoiceProcurementLogRepository, VoiceProcurementLogRepository>();


// Add Services
builder.Services.AddScoped<IProcurementService, ProcurementService>();
builder.Services.AddScoped<IOrderExecutionService, OrderExecutionService>();
builder.Services.AddScoped<IOrderQueryService, OrderQueryService>();
builder.Services.AddScoped<IInventoryService, InventoryService>();
builder.Services.AddScoped<IMerchantDashboardService, MerchantDashboardService>();
builder.Services.AddScoped<ICatalogService, CatalogService>();
builder.Services.AddScoped<IBiddingService, BiddingService>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IEmailService, EmailService>();
builder.Services.AddScoped<IDemoSeederService, DemoSeederService>();
builder.Services.AddScoped<IPaymentService, StripePaymentService>();
builder.Services.AddScoped<IPayTabsService, PayTabsService>();

Stripe.StripeConfiguration.ApiKey = builder.Configuration["Stripe:SecretKey"];

// Voice order pipeline (SignalR + background AI worker)
builder.Services.AddSingleton<IBackgroundQueue, BackgroundQueue>();
builder.Services.AddHttpClient<IAIService, AIService>(client =>
{
    client.BaseAddress = new Uri(builder.Configuration["AiService:BaseUrl"] ?? "http://localhost:8000");
    client.Timeout = TimeSpan.FromSeconds(builder.Configuration.GetValue("AiService:TimeoutSeconds", 120));
});
builder.Services.AddHttpClient<IAISyncService, AISyncService>(client =>
{
    client.BaseAddress = new Uri(builder.Configuration["AiService:BaseUrl"] ?? "http://localhost:8000");
    client.Timeout = TimeSpan.FromSeconds(builder.Configuration.GetValue("AiService:TimeoutSeconds", 120));
});
builder.Services.AddSingleton<INotificationService, NotificationService>();
builder.Services.AddScoped<ISupplierAssignmentService, SupplierAssignmentService>();
builder.Services.AddHostedService<VoiceProcessingWorker>();
builder.Services.AddHostedService<CatalogSyncWorker>();

// RAG knowledge base indexing pipeline (same shape as the voice pipeline above)
builder.Services.AddSingleton<IKnowledgeIndexingQueue, KnowledgeIndexingQueue>();
builder.Services.AddHostedService<KnowledgeIndexingWorker>();

builder.Services.AddSignalR(options =>
{
    options.MaximumReceiveMessageSize = 10 * 1024 * 1024;
})
.AddJsonProtocol(options =>
{
    options.PayloadSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
});

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.SetIsOriginAllowed(_ => true)
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials();
    });
});

builder.Services.AddControllers().AddJsonOptions(options => 
{
    options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
    options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter());
});
builder.Services.AddFluentValidationAutoValidation();
builder.Services.AddValidatorsFromAssemblyContaining<RegisterRequestDtoValidator>();
builder.Services.AddHealthChecks();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Salasel API", Version = "v1" });

    // Configure Swagger to send JWT token
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Enter your valid token in the text input below.\r\n\r\nExample: \"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...\""
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            new string[] {}
        }
    });
});


var app = builder.Build();

// ── Auto-apply EF Core migrations on startup ────────────────────────────────
bool migrationSuccess = true;
string? migrationError = null;

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<SalaselDbContext>();
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    try
    {
        logger.LogInformation("Applying database migrations...");
        db.Database.Migrate();
        logger.LogInformation("Database migrations applied successfully.");

        logger.LogInformation("Seeding database...");
        await Salasel.Infrastructure.Data.DatabaseSeeder.SeedAsync(db);
        logger.LogInformation("Database seeding applied successfully.");

        // --- One-Time Auto Sync ---
        logger.LogInformation("Auto-syncing historical completed orders to inventory...");
        var allMerchants = await db.MerchantsProfiles.Select(m => m.MerchantID).ToListAsync();
        foreach (var mId in allMerchants)
        {
            var existingInventory = await db.MerchantInventories.Where(i => i.MerchantID == mId).ToListAsync();
            foreach (var item in existingInventory) item.CurrentQty = 0;
            
            var completedOrders = await db.MasterOrders
                .Include(o => o.SubOrders)
                .Where(o => o.MerchantId == mId && o.Status == Salasel.Domain.Enums.ApprovalStatus.Completed)
                .ToListAsync();
                
            var qtyMap = new Dictionary<int, int>();
            foreach (var order in completedOrders)
            {
                if (order.SubOrders == null) continue;
                foreach (var sub in order.SubOrders)
                {
                    if (sub.Status == Salasel.Domain.Enums.FulfillmentStatus.ReceiptConfirmed && sub.ProductId.HasValue)
                    {
                        if (!qtyMap.ContainsKey(sub.ProductId.Value))
                            qtyMap[sub.ProductId.Value] = 0;
                        qtyMap[sub.ProductId.Value] += sub.Quantity;
                    }
                }
            }
            
            foreach (var kvp in qtyMap)
            {
                var productId = kvp.Key;
                var qty = kvp.Value;
                var existingItem = existingInventory.FirstOrDefault(i => i.ProductId == productId);
                if (existingItem != null)
                {
                    existingItem.CurrentQty = qty;
                    existingItem.LastUpdated = DateTime.UtcNow;
                }
                else
                {
                    var newItem = new Salasel.Domain.Entities.MerchantInventory
                    {
                        MerchantID = mId,
                        ProductId = productId,
                        CurrentQty = qty,
                        ReorderThreshold = 10,
                        LastUpdated = DateTime.UtcNow
                    };
                    db.MerchantInventories.Add(newItem);
                }
            }
        }
        await db.SaveChangesAsync();
        logger.LogInformation("Auto-syncing historical completed orders completed.");
        // --- End One-Time Auto Sync ---
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "Failed to apply database migrations.");
        migrationSuccess = false;
        migrationError = ex.Message;
        // We purposely do NOT throw here anymore.
        // This ensures the API server stays alive even if the DB is down,
        // allowing Nginx to route traffic and us to see the /api/diagnostics page.
    }
}

if (app.Environment.IsDevelopment() || app.Environment.IsProduction())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseMiddleware<GlobalExceptionMiddleware>();
app.UseMiddleware<LangfuseMiddleware>();

// app.UseHttpsRedirection(); // Disabled because Nginx handles HTTPS termination
app.UseStaticFiles();

app.UseSerilogRequestLogging(); // <-- Records HTTP request times extremely fast


app.UseCors("AllowAll");

app.UseAuthentication();
app.UseAuthorization();

app.MapHub<NotificationHub>("/notificationHub");
app.MapControllers();
app.MapHealthChecks("/health");

app.MapGet("/api/diagnostics", async (SalaselDbContext db, IConfiguration config) =>
{
    bool dbCanConnect = false;
    string? dbError = null;

    try
    {
        dbCanConnect = await db.Database.CanConnectAsync();
    }
    catch (Exception ex)
    {
        dbError = ex.Message;
    }

    return Results.Ok(new
    {
        status = "API is running and reachable by Nginx!",
        serverTimeUtc = DateTime.UtcNow,
        environment = app.Environment.EnvironmentName,
        database = new
        {
            connectionStringConfigured = !string.IsNullOrEmpty(config.GetConnectionString("DefaultConnection")),
            canConnectNow = dbCanConnect,
            connectionTestError = dbError,
            startupMigrationSuccess = migrationSuccess,
            startupMigrationError = migrationError
        },
        jwt = new
        {
            keyConfigured = !string.IsNullOrEmpty(config["Jwt:Key"])
        }
    });
});

app.Run();