using Microsoft.AspNetCore.Mvc;

namespace PharmaApi.Controllers;

public class StockDto
{
    public int Id { get; set; }
    public string Product { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public double Price { get; set; }
    public int UserId { get; set; }
    public string UserName { get; set; } = string.Empty;
    public string CreatedAt { get; set; } = string.Empty;
}

[ApiController]
[Route("api/[controller]")]
public class StockController : ControllerBase
{
    [HttpGet("all")]
    public IActionResult GetAllPublic()
    {
        var now = DateTime.UtcNow.ToString("o");
        var list = new List<StockDto>
        {
            new StockDto { Id = 1, Product = "Paracetamol 500mg", Category = "Painkiller", Quantity = 50, Price = 2.5, UserId = 1, UserName = "Central Pharmacy", CreatedAt = now },
            new StockDto { Id = 2, Product = "Cough Syrup", Category = "Cold & Flu", Quantity = 20, Price = 5.0, UserId = 2, UserName = "HealthPlus Pharmacy", CreatedAt = now },
            new StockDto { Id = 3, Product = "Antibiotic Capsule", Category = "Antibiotics", Quantity = 10, Price = 12.0, UserId = 3, UserName = "Neighborhood Pharmacy", CreatedAt = now }
        };

        return Ok(list);
    }
}
