import 'package:mysql1/mysql1.dart';

/// Configuration helper for connecting to local databases.
///
/// Note: The original project used a direct MySQL connection via `mysql1`.
/// Windows Integrated Authentication ("Integrated Security") is a feature of
/// Microsoft SQL Server (MSSQL) and is not applicable to MySQL. If you want
/// to use MSSQL with Windows Authentication you typically run the DB access
/// from a backend (ASP.NET Core, Node, etc.) rather than directly from Flutter.
class DatabaseConfig {
  // --- MySQL (kept for compatibility) ---
  static const String host = '127.0.0.1'; // or your LAN IP
  static const int port = 3306;
  static const String user = 'root';
  static const String password = 'password';
  static const String databaseName = 'pharmaHubDb';

  /// Default table names used by the SQL helpers.
  static const String pharmacyTable = 'pharmacies';

  /// Builds a [ConnectionSettings] instance for mysql1.
  static ConnectionSettings get settings => ConnectionSettings(
        host: host,
        port: port,
        user: user,
        password: password,
        db: databaseName,
        timeout: const Duration(seconds: 5),
      );

  // --- Microsoft SQL Server (MSSQL) ---
  // If you need to use Windows Authentication (Integrated Security) with
  // SQL Server, here's a connection string example. This is intended for a
  // backend (C#, .NET) or other server-side component that supports
  // Integrated Security. Flutter/Dart does not natively support MS SQL
  // Integrated Authentication from a client app.
  //
  // Server name requested: DESKTOP-HK2BVS1
  // Database: pharmaHubDb (change if different)
  // Example (Windows Authentication / Integrated Security):
  // "Server=DESKTOP-HK2BVS1;Database=pharmaHubDb;Integrated Security=true;TrustServerCertificate=True;"

  /// MSSQL connection string for backend use (Integrated Security / Windows Auth)
  /// Note: keep secrets out of source control; use environment variables or
  /// a secrets manager for production credentials.
  static const String mssqlIntegratedConnectionString =
      'Server=DESKTOP-HK2BVS1;Database=pharmaHubDb;Integrated Security=true;TrustServerCertificate=True;';

  /// Example MSSQL connection string using SQL Authentication (if you prefer)
  /// static const String mssqlSqlAuthConnectionString =
  ///     'Server=DESKTOP-HK2BVS1,1433;Database=pharmaHubDb;User Id=sa;Password=YOUR_PASSWORD_HERE;TrustServerCertificate=True;';
}
