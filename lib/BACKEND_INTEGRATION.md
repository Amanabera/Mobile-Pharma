# Backend Integration Guide

This document explains how the Flutter app connects to the backend API.

## API Configuration

The API base URL is configured in `lib/config/api_config.dart`. Update it based on your environment:

- **Android Emulator**: `http://10.0.2.2:5170/api`
- **iOS Simulator**: `http://localhost:5170/api`
- **Physical Device**: `http://YOUR_COMPUTER_IP:5170/api` (e.g., `http://192.168.1.100:5170/api`)
- **Web/Chrome**: `http://localhost:5170/api`

## Authentication Endpoints

### Signup
- **Endpoint**: `POST /api/auth/signup`
- **Request Body**:
  ```json
  {
    "fullName": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "role": "pharmacyOwner" // or "customer"
  }
  ```
- **Response**:
  ```json
  {
    "message": "User registered successfully",
    "fullName": "John Doe",
    "role": "PharmacyOwner",
    "token": "jwt_token_here",
    "status": "Pending", // or "Active", "Blocked"
    "email": "john@example.com"
  }
  ```

### Login
- **Endpoint**: `POST /api/auth/login`
- **Request Body**:
  ```json
  {
    "email": "john@example.com",
    "password": "password123"
  }
  ```
- **Response**:
  ```json
  {
    "message": "Login successful",
    "fullName": "John Doe",
    "role": "PharmacyOwner",
    "token": "jwt_token_here",
    "status": "Active",
    "email": "john@example.com"
  }
  ```

### Check User Status
- **Endpoint**: `GET /api/auth/status/{email}`
- **Headers**: `Authorization: Bearer {token}`
- **Response**:
  ```json
  {
    "status": "Active" // or "Pending", "Blocked"
  }
  ```

## Usage Examples

### Login Example
```dart
import '../services/auth_service.dart';
import '../models/auth_models.dart';

final authService = AuthService();
final loginData = LoginData(
  email: 'user@example.com',
  password: 'password123',
);

try {
  final response = await authService.login(loginData);
  
  if (response.isActive) {
    await authService.storeLoginInfo(response);
    // Navigate to dashboard
  } else if (response.isPending) {
    // Show pending message
  } else if (response.isBlocked) {
    // Show blocked message
  }
} catch (e) {
  // Handle error
  print('Login failed: $e');
}
```

### Signup Example
```dart
import '../services/auth_service.dart';
import '../models/auth_models.dart';

final authService = AuthService();
final signupData = SignupData(
  fullName: 'John Doe',
  email: 'john@example.com',
  password: 'password123',
  role: 'customer',
);

try {
  final response = await authService.signup(signupData);
  // Show success message
} catch (e) {
  // Handle error
  print('Signup failed: $e');
}
```

### Making Authenticated Requests
```dart
import '../utils/http_client.dart';
import '../config/api_config.dart';

final httpClient = HttpClient();

// GET request with authentication
final response = await httpClient.get(
  ApiConfig.pharmacyEndpoint,
  requiresAuth: true,
);

if (response.statusCode == 200) {
  // Process response
}
```

### Checking Login Status
```dart
final authService = AuthService();
final isLoggedIn = await authService.isLoggedIn();

if (isLoggedIn) {
  final token = await authService.getToken();
  final role = await authService.getRole();
  final email = await authService.getEmail();
  final fullName = await authService.getFullName();
}
```

### Logout
```dart
final authService = AuthService();
await authService.logout();
// Navigate to login screen
```

## File Structure

```
lib/
├── config/
│   └── api_config.dart          # API endpoints configuration
├── models/
│   └── auth_models.dart        # Auth data models (SignupData, LoginData, AuthResponse)
├── services/
│   ├── auth_service.dart       # Authentication service
│   ├── pharmacy_service.dart   # Pharmacy API service
│   └── stock_service.dart      # Stock/Medicine API service
└── utils/
    └── http_client.dart        # HTTP client utility with auth support
```

## Error Handling

All API calls throw `Exception` with descriptive error messages. Always wrap API calls in try-catch blocks:

```dart
try {
  final response = await authService.login(loginData);
  // Handle success
} catch (e) {
  // Handle error
  final errorMessage = e.toString().replaceFirst('Exception: ', '');
  // Show error to user
}
```

## Token Storage

Tokens are stored securely using `SharedPreferences`. The `AuthService` handles all token management automatically.

## Account Status

The backend supports three account statuses:
- **Active**: User can login and use the app
- **Pending**: User registered but waiting for admin approval
- **Blocked**: User account is blocked by admin

The app handles each status appropriately:
- Active users proceed to dashboard
- Pending users see a message to wait for approval
- Blocked users see a message to contact admin

## Next Steps

1. Update `lib/config/api_config.dart` with your backend URL
2. Test login/signup flows
3. Implement role-based navigation if needed
4. Add SignalR support for real-time status updates (optional)

## Direct MySQL Connection (Local Testing)

If the REST API is unavailable you can point the Flutter app directly at a local **MySQL** server.

### Configure credentials

Edit `lib/config/database_config.dart`:

```dart
class DatabaseConfig {
  static const String host = '127.0.0.1';   // Use 10.0.2.2 for Android emulator
  static const int port = 3306;
  static const String user = 'root';
  static const String password = 'password';
  static const String databaseName = 'pharmahub';
  static const String pharmacyTable = 'pharmacies';
}
```

For Android emulator use `10.0.2.2` instead of `127.0.0.1`. For physical devices, use your PC's LAN IP (e.g. `192.168.1.50`).

### Sample schema

```sql
CREATE TABLE pharmacies (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pharmacy_name VARCHAR(150) NOT NULL,
  address VARCHAR(255) NOT NULL,
  phone_number VARCHAR(50) NOT NULL,
  email VARCHAR(150),
  description TEXT
);
```

Insert seed data:

```sql
INSERT INTO pharmacies (pharmacy_name, address, phone_number, email, description)
VALUES
('Central Pharma', '123 Main St', '+1 555-111-2222', 'info@centralpharma.com', '24/7 downtown pharmacy'),
('Green Leaf Pharmacy', '45 Oak Ave', '+1 555-333-4444', 'hello@greenleaf.com', 'Organic wellness supplies');
```

### Enable SQL mode in Flutter

`PharmacyService` now accepts `useSqlBackend` (defaults to `false`). `PharmaListScreen` is already instantiated with `useSqlBackend: true`, so as soon as MySQL is reachable the list will load from your database.

You can toggle between API and SQL simply by changing the constructor:

```dart
final service = PharmacyService(useSqlBackend: true); // direct MySQL
final service = PharmacyService(useSqlBackend: false); // REST API
```

### Security notes

- Direct DB access is intended for local development only.
- For production always route Flutter → secure API → database.
- Never hardcode production passwords; use env variables or a secrets manager.

## Next Steps

1. Update `lib/config/api_config.dart` with your backend URL
2. Update `lib/config/database_config.dart` with your MySQL credentials
3. Ensure the `pharmacies` table exists locally
4. Run `flutter pub get` then `flutter run`

## SQL Server (MSSQL) Connection – IP 196.190.251.194

If your backend API runs against Microsoft SQL Server instead of MySQL, configure the connection string on the server-side (e.g. ASP.NET Core, Node, etc.). Example:

```
Server=196.190.251.194,1433;Database=PharmaHubDb;User Id=sa;Password=YOUR_STRONG_PASSWORD;TrustServerCertificate=True;MultipleActiveResultSets=True;
```

### ASP.NET Core example

`appsettings.Development.json`

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=196.190.251.194,1433;Database=PharmaHubDb;User Id=sa;Password=YOUR_STRONG_PASSWORD;TrustServerCertificate=True;MultipleActiveResultSets=True;"
  }
}
```

`Program.cs`

```csharp
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));
```

### Security tips

- Replace `YOUR_STRONG_PASSWORD` with a real password and avoid committing it to source control.
- Create a dedicated SQL login with limited permissions instead of using `sa` in production.
- Prefer environment variables, secret managers, or CI/CD secrets for storing credentials (e.g. `ConnectionStrings__DefaultConnection=...`).

### Flutter consideration

Flutter still talks to your REST API. The API is what connects to SQL Server using the connection string above. If you need direct SQL Server access in Flutter, plan for a custom plugin/native bridge; direct TDS connections from Dart are not officially supported.

