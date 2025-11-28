namespace PharmaApi.Models;

public class User
{
    public int Id { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty; // store hash in prod
    public string Role { get; set; } = "customer";
    public string Status { get; set; } = "Active"; // Active | Pending | Blocked
}
