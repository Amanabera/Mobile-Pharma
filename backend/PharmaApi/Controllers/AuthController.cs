using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.DependencyInjection;
using PharmaApi.Models;
using PharmaApi.Data;

namespace PharmaApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    // Optional AppDbContext: may not be registered in development (no connection string)
    private readonly AppDbContext? _db;
    private readonly PasswordHasher<User> _hasher = new();

    // In-memory fallback store when DB is not available
    private static readonly List<User> _inMemoryUsers = new();
    private static int _nextId = 1;

    public AuthController(IServiceProvider services)
    {
        // Try to resolve AppDbContext; will be null if not registered
        _db = services.GetService<AppDbContext>();
    }

    [HttpPost("signup")]
    public IActionResult Signup([FromBody] SignupRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.Email) || string.IsNullOrWhiteSpace(req.Password))
            return BadRequest(new { message = "Email and password are required." });

        var email = req.Email.ToLowerInvariant();

        // If DB available, persist
        if (_db != null)
        {
            if (_db.Users.Any(u => u.Email == email))
                return Conflict(new { message = "User already exists." });

            var user = new User
            {
                FullName = req.FullName ?? string.Empty,
                Email = email,
                Role = req.Role ?? "customer",
                Status = "Active"
            };

            user.PasswordHash = _hasher.HashPassword(user, req.Password);

            _db.Users.Add(user);
            _db.SaveChanges();

            var token = Guid.NewGuid().ToString();

            return Created(string.Empty, new
            {
                message = "User registered successfully",
                fullName = user.FullName,
                role = user.Role,
                token = token,
                status = user.Status,
                email = user.Email
            });
        }

        // Fallback to in-memory store for development when DB not configured
        var existing = _inMemoryUsers.FirstOrDefault(u => u.Email.Equals(email, StringComparison.OrdinalIgnoreCase));
        if (existing != null)
            return Conflict(new { message = "User already exists." });

        var memUser = new User
        {
            Id = _nextId++,
            FullName = req.FullName ?? string.Empty,
            Email = email,
            Role = req.Role ?? "customer",
            Status = "Active"
        };

        memUser.PasswordHash = _hasher.HashPassword(memUser, req.Password);
        _inMemoryUsers.Add(memUser);

        var memToken = Guid.NewGuid().ToString();

        return Created(string.Empty, new
        {
            message = "User registered successfully (in-memory)",
            fullName = memUser.FullName,
            role = memUser.Role,
            token = memToken,
            status = memUser.Status,
            email = memUser.Email
        });
    }

    [HttpPost("login")]
    public IActionResult Login([FromBody] LoginRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.Email) || string.IsNullOrWhiteSpace(req.Password))
            return BadRequest(new { message = "Email and password are required." });

        var email = req.Email.ToLowerInvariant();

        if (_db != null)
        {
            var user = _db.Users.FirstOrDefault(u => u.Email == email);
            if (user == null)
                return Unauthorized(new { message = "Invalid credentials." });

            var verify = _hasher.VerifyHashedPassword(user, user.PasswordHash, req.Password);
            if (verify == PasswordVerificationResult.Failed)
                return Unauthorized(new { message = "Invalid credentials." });

            var token = Guid.NewGuid().ToString();
            return Ok(new
            {
                message = "Login successful",
                fullName = user.FullName,
                role = user.Role,
                token = token,
                status = user.Status,
                email = user.Email
            });
        }

        var mem = _inMemoryUsers.FirstOrDefault(u => u.Email.Equals(email, StringComparison.OrdinalIgnoreCase));
        if (mem == null)
            return Unauthorized(new { message = "Invalid credentials." });

        var memVerify = _hasher.VerifyHashedPassword(mem, mem.PasswordHash, req.Password);
        if (memVerify == PasswordVerificationResult.Failed)
            return Unauthorized(new { message = "Invalid credentials." });

        var memToken2 = Guid.NewGuid().ToString();
        return Ok(new
        {
            message = "Login successful",
            fullName = mem.FullName,
            role = mem.Role,
            token = memToken2,
            status = mem.Status,
            email = mem.Email
        });
    }
    // Add this to PharmaApi/Controllers/AuthController.cs

    [HttpGet("status/{email}")]
    public IActionResult GetStatus(string email)
    {
        // 1. Try Database
        if (_db != null)
        {
            var user = _db.Users.FirstOrDefault(u => u.Email == email);
            if (user == null) return NotFound(new { message = "User not found" });
            return Ok(new { status = user.Status, role = user.Role });
        }

        // 2. Fallback to Memory please please
        var memUser = _inMemoryUsers.FirstOrDefault(u => u.Email.Equals(email, StringComparison.OrdinalIgnoreCase));
        if (memUser == null) return NotFound(new { message = "User not found" });

        return Ok(new { status = memUser.Status, role = memUser.Role });
    }
}

public record SignupRequest(string? FullName, string Email, string Password, string? Role);
public record LoginRequest(string Email, string Password);
