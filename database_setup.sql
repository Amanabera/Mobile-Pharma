-- =============================================
-- PharmaHub Database Setup Script for MSSQL
-- Server: DESKTOP-HK2BVS1
-- =============================================

-- Step 1: Create the Database
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'PharmaHubDb')
BEGIN
    CREATE DATABASE PharmaHubDb;
    PRINT 'Database PharmaHubDb created successfully.';
END
ELSE
BEGIN
    PRINT 'Database PharmaHubDb already exists.';
END
GO

USE PharmaHubDb;
GO

-- Step 2: Create Users Table (for authentication)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE Users (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        FullName NVARCHAR(150) NOT NULL,
        Email NVARCHAR(150) NOT NULL UNIQUE,
        PasswordHash NVARCHAR(255) NOT NULL,
        Role NVARCHAR(50) NOT NULL, -- 'PharmacyOwner', 'Customer', 'Admin'
        Status NVARCHAR(20) NOT NULL DEFAULT 'Pending', -- 'Active', 'Pending', 'Blocked'
        CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Table Users created successfully.';
END
ELSE
BEGIN
    PRINT 'Table Users already exists.';
END
GO

-- Step 3: Create Pharmacies Table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Pharmacies')
BEGIN
    CREATE TABLE Pharmacies (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        PharmacyName NVARCHAR(150) NOT NULL,
        Address NVARCHAR(255) NOT NULL,
        PhoneNumber NVARCHAR(50) NOT NULL,
        Email NVARCHAR(150) NULL,
        Description NVARCHAR(MAX) NULL,
        OwnerId INT NULL, -- Foreign key to Users table (if pharmacy owner)
        CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_Pharmacies_Users FOREIGN KEY (OwnerId) REFERENCES Users(Id)
    );
    PRINT 'Table Pharmacies created successfully.';
END
ELSE
BEGIN
    PRINT 'Table Pharmacies already exists.';
END
GO

-- Step 4: Create Stock/Medicines Table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Stock')
BEGIN
    CREATE TABLE Stock (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        MedicineName NVARCHAR(150) NOT NULL,
        Category NVARCHAR(100) NULL,
        Description NVARCHAR(MAX) NULL,
        Price DECIMAL(10,2) NOT NULL,
        Quantity INT NOT NULL DEFAULT 0,
        PharmacyId INT NULL, -- Foreign key to Pharmacies table
        CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_Stock_Pharmacies FOREIGN KEY (PharmacyId) REFERENCES Pharmacies(Id)
    );
    PRINT 'Table Stock created successfully.';
END
ELSE
BEGIN
    PRINT 'Table Stock already exists.';
END
GO

-- Step 5: Create Indexes for Better Performance
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Users_Email')
BEGIN
    CREATE INDEX IX_Users_Email ON Users(Email);
    PRINT 'Index IX_Users_Email created.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Users_Status')
BEGIN
    CREATE INDEX IX_Users_Status ON Users(Status);
    PRINT 'Index IX_Users_Status created.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Pharmacies_OwnerId')
BEGIN
    CREATE INDEX IX_Pharmacies_OwnerId ON Pharmacies(OwnerId);
    PRINT 'Index IX_Pharmacies_OwnerId created.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Stock_PharmacyId')
BEGIN
    CREATE INDEX IX_Stock_PharmacyId ON Stock(PharmacyId);
    PRINT 'Index IX_Stock_PharmacyId created.';
END
GO

-- Step 6: Insert Sample Data (Optional)
-- =============================================
-- Uncomment the following section if you want sample data

/*
-- Sample Pharmacies
INSERT INTO Pharmacies (PharmacyName, Address, PhoneNumber, Email, Description)
VALUES 
    ('City Pharmacy', '123 Main Street, City Center', '555-0101', 'info@citypharmacy.com', 'Your trusted neighborhood pharmacy'),
    ('Health Plus', '456 Oak Avenue, Downtown', '555-0102', 'contact@healthplus.com', 'Quality medicines at affordable prices'),
    ('MediCare Pharmacy', '789 Pine Road, Uptown', '555-0103', 'hello@medicarepharm.com', 'Professional healthcare services');

-- Sample Stock (if you have pharmacy IDs)
-- Note: Adjust PharmacyId values based on actual pharmacy IDs from above
INSERT INTO Stock (MedicineName, Category, Description, Price, Quantity, PharmacyId)
VALUES 
    ('Paracetamol 500mg', 'Pain Relief', 'Effective pain and fever relief', 5.99, 100, 1),
    ('Ibuprofen 400mg', 'Pain Relief', 'Anti-inflammatory medication', 7.50, 80, 1),
    ('Amoxicillin 250mg', 'Antibiotics', 'Broad spectrum antibiotic', 12.99, 50, 2),
    ('Vitamin D3', 'Supplements', 'Essential vitamin supplement', 9.99, 200, 2),
    ('Cough Syrup', 'Cold & Flu', 'Relieves cough and throat irritation', 8.50, 60, 3);
*/

PRINT 'Database setup completed successfully!';
GO

