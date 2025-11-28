# MSSQL Database Setup Guide for PharmaHub

This guide will help you create and configure the PharmaHub database on your MSSQL Server at `196.190.251.194`.

## Prerequisites

- SQL Server Management Studio (SSMS) installed, OR
- `sqlcmd` command-line tool, OR
- Azure Data Studio
- Access credentials to SQL Server (sa account or user with CREATE DATABASE permission)

---

## Method 1: Using SQL Server Management Studio (SSMS) - Recommended

### Step 1: Connect to SQL Server

1. Open **SQL Server Management Studio (SSMS)**
2. In the **Connect to Server** dialog:
   - **Server type**: Database Engine
   - **Server name**: `196.190.251.194,1433` (or just `196.190.251.194`)
   - **Authentication**: SQL Server Authentication
   - **Login**: `sa` (or your SQL login)
   - **Password**: Your SQL Server password
3. Click **Connect**

### Step 2: Run the Setup Script

1. In SSMS, click **File** → **Open** → **File**
2. Navigate to `database_setup.sql` (in your project root)
3. Click **Execute** (F5) or click the **Execute** button
4. Check the **Messages** tab for success messages

### Step 3: Verify Database Creation

1. In **Object Explorer**, expand **Databases**
2. You should see **PharmaHubDb** listed
3. Expand **PharmaHubDb** → **Tables** to see:
   - `Users`
   - `Pharmacies`
   - `Stock`

---

## Method 2: Using sqlcmd (Command Line)

### Windows Command Prompt or PowerShell

```bash
# Connect and run the script
sqlcmd -S 196.190.251.194,1433 -U sa -P "YourPassword" -i database_setup.sql
```

**Note**: Replace `YourPassword` with your actual SQL Server password.

### If you get connection errors:

1. **Check SQL Server is running** and accessible
2. **Verify firewall** allows port 1433
3. **Enable TCP/IP** in SQL Server Configuration Manager:
   - Open SQL Server Configuration Manager
   - Go to **SQL Server Network Configuration** → **Protocols for [Instance]**
   - Enable **TCP/IP**
   - Restart SQL Server service

---

## Method 3: Using Azure Data Studio

1. Open **Azure Data Studio**
2. Click **New Connection**
3. Enter connection details:
   - **Server**: `196.190.251.194,1433`
   - **Authentication type**: SQL Login
   - **User name**: `sa`
   - **Password**: Your password
4. Click **Connect**
5. Open `database_setup.sql` and run it (Ctrl+Shift+E)

---

## Verify Database Setup

Run this query to verify everything was created:

```sql
USE PharmaHubDb;
GO

-- Check tables
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE';

-- Check Users table structure
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Users';

-- Check Pharmacies table structure
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Pharmacies';
```

---

## Connection String for Your Backend

Once the database is created, use this connection string in your backend:

```
Server=196.190.251.194,1433;
Database=PharmaHubDb;
User Id=sa;
Password=YOUR_PASSWORD;
TrustServerCertificate=True;
MultipleActiveResultSets=True;
```

**Security Note**: 
- Replace `YOUR_PASSWORD` with your actual password
- Consider creating a dedicated SQL user instead of using `sa` (see below)

---

## Create a Dedicated SQL User (Recommended)

Instead of using `sa`, create a dedicated user with limited permissions:

```sql
USE PharmaHubDb;
GO

-- Create login
CREATE LOGIN PharmaAppUser WITH PASSWORD = 'StrongPassword123!';
GO

-- Create user in database
CREATE USER PharmaAppUser FOR LOGIN PharmaAppUser;
GO

-- Grant permissions (db_owner for full access, or customize as needed)
ALTER ROLE db_owner ADD MEMBER PharmaAppUser;
GO
```

Then use this connection string:

```
Server=196.190.251.194,1433;
Database=PharmaHubDb;
User Id=PharmaAppUser;
Password=StrongPassword123!;
TrustServerCertificate=True;
MultipleActiveResultSets=True;
```

---

## Troubleshooting

### Error: "Cannot connect to server"
- **Check SQL Server is running** on the server
- **Verify port 1433** is open in firewall
- **Enable TCP/IP** in SQL Server Configuration Manager
- **Check SQL Server Browser** service is running (if using named instances)

### Error: "Login failed"
- Verify username and password are correct
- Check SQL Server Authentication is enabled (not just Windows Authentication)
- Ensure the user has permission to create databases

### Error: "Database already exists"
- The script will skip creation if database exists
- To recreate, first drop the database:
  ```sql
  DROP DATABASE PharmaHubDb;
  GO
  ```
  Then run `database_setup.sql` again

---

## Next Steps

1. ✅ Database created
2. ✅ Tables created
3. 🔄 Update your backend connection string
4. 🔄 Test API endpoints
5. 🔄 Connect Flutter app to backend

---

## Sample Data (Optional)

To insert sample pharmacies and stock, uncomment the sample data section in `database_setup.sql` and run it again, or manually insert data:

```sql
USE PharmaHubDb;
GO

INSERT INTO Pharmacies (PharmacyName, Address, PhoneNumber, Email, Description)
VALUES 
    ('City Pharmacy', '123 Main Street', '555-0101', 'info@citypharmacy.com', 'Your trusted pharmacy');

INSERT INTO Stock (MedicineName, Category, Description, Price, Quantity, PharmacyId)
VALUES 
    ('Paracetamol 500mg', 'Pain Relief', 'Pain and fever relief', 5.99, 100, 1);
```

---

## Support

If you encounter issues:
1. Check SQL Server error logs
2. Verify network connectivity to `196.190.251.194:1433`
3. Ensure SQL Server allows remote connections
4. Check firewall rules

