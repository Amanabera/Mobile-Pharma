using Microsoft.AspNetCore.Mvc;

namespace PharmaApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PharmacyDto
{
    public int Id { get; set; }
    public string PharmacyName { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string? Email { get; set; }
    public string? Description { get; set; }
}

[ApiController]
[Route("api/[controller]")]
public class PharmaciesController : ControllerBase
{
    // Responds to both /api/pharmacies (controller-based) and /api/pharmacy (singular)
    [HttpGet]
    [HttpGet("/api/pharmacy")]
    public IActionResult GetAll()
    {
        var list = new List<PharmacyDto>
        {
            new PharmacyDto { Id = 1, PharmacyName = "Central Pharmacy", Address = "Addis Ababa, Ethiopia", PhoneNumber = "09876543243", Email = "central@example.com" },
            new PharmacyDto { Id = 2, PharmacyName = "HealthPlus Pharmacy", Address = "Addis Ababa, Ethiopia", PhoneNumber = "09876543243", Email = "health@example.com" },
            new PharmacyDto { Id = 3, PharmacyName = "Neighborhood Pharmacy", Address = "Addis Ababa, Ethiopia", PhoneNumber = "09876543243" }
        };

        return Ok(list);
    }
}
