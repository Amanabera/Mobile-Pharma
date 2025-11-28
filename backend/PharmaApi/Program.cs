using Microsoft.EntityFrameworkCore;
using PharmaApi.Data;

var builder = WebApplication.CreateBuilder(args);

// Allow the API to be reachable from emulators/devices during development
var corsPolicyName = "AllowDev";
builder.Services.AddCors(options =>
{
    options.AddPolicy(corsPolicyName, policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// Load connection string from configuration (appsettings or environment variable)
// Load connection string from configuration (appsettings or environment variable)
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

// Add DB context only if a connection string is configured. This allows
// running the API without a database for development/testing (the
// AuthController uses an in-memory user store).
if (!string.IsNullOrWhiteSpace(connectionString))
{
    builder.Services.AddDbContext<AppDbContext>(options =>
        options.UseSqlServer(connectionString));
}
else
{
    // No DB connection configured — skip registering AppDbContext to avoid
    // runtime exceptions. Log a warning so developers know to configure a DB
    // if they expect persistence.
    Console.WriteLine("Warning: No DefaultConnection configured. Skipping DbContext registration.");
}

builder.Services.AddControllers();

// Listen on all network interfaces so emulators and other devices can reach the host
builder.WebHost.UseUrls("http://0.0.0.0:5000");

var app = builder.Build();

app.UseCors(corsPolicyName);

app.MapGet("/", () => Results.Ok(new { message = "PharmaApi running" }));
app.MapControllers();

app.Run();
