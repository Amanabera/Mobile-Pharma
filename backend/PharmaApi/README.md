# PharmaApi (minimal scaffold)

This is a minimal ASP.NET Core Web API scaffold to act as a backend for the Flutter `pharmacy_app`.
It demonstrates how to configure the SQL Server connection string using Windows Integrated Authentication (Integrated Security) and how the Flutter app should call the backend's HTTP endpoints.

## Key points

- Integrated Security (Windows Authentication) is supported by SQL Server and works when the backend runs under a Windows account that has access to the database.
- Do NOT attempt to use Integrated Security from a Flutter client. Instead, run the backend on the same machine or domain where SQL Server trust works, and the backend will connect to SQL Server using Integrated Security.

## Development setup

1. Install .NET SDK (7.0 or later).
2. From this folder run:

```powershell
cd backend\PharmaApi
dotnet restore
dotnet build
```

3. Provide a connection string. Options:

- Copy `appsettings.Development.json.example` to `appsettings.Development.json` and edit if needed.
- Or set an environment variable for the current session (PowerShell):

```powershell
$env:ConnectionStrings__DefaultConnection = "Server=DESKTOP-HK2BVS1;Database=pharmaHubDb;Integrated Security=true;TrustServerCertificate=True;"
```

4. Run the API:

```powershell
dotnet run
```

The API will print a listening URL (by default `http://localhost:5000` / `https://localhost:5001` depending on configuration). You can then point the Flutter app's `ApiConfig.baseUrl` to the appropriate address (for example `http://10.0.2.2:5000/api` if using an Android emulator and the API binds to localhost on the host machine).

## Use with Flutter app

- For Android emulator, use `http://10.0.2.2:{port}/api`.
- For iOS simulator or desktop, use `http://localhost:{port}/api`.
- For a physical device, use `http://<your-machine-ip>:{port}/api`.

## Notes

- Create a least-privilege SQL Server login instead of using `sa` for production. If you cannot use Integrated Security, use SQL Authentication with a dedicated user and store secrets in environment variables or a secret manager.
- This scaffold is minimal; extend with controllers, DTOs, authentication, and validation as needed.
