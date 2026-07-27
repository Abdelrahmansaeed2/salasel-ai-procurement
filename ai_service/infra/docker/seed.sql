IF DB_ID(N'SalaselAiService') IS NULL
BEGIN
    CREATE DATABASE SalaselAiService;
END
GO

USE SalaselAiService;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierProfiles WHERE CompanyName = N'Cairo Wholesale Co')
BEGIN
    INSERT INTO dbo.SupplierProfiles
        (CompanyName, ReliabilityScore, PaymentTerms, IsActiveForRouting, Latitude, Longitude, Location)
    VALUES
        (N'Cairo Wholesale Co', 94.50, N'Net 30', 1, 30.0444, 31.2357, geography::STGeomFromText('POINT(31.2357 30.0444)', 4326)),
        (N'Alexandria Industrial Supply', 88.25, N'Net 15', 1, 31.2001, 29.9187, geography::STGeomFromText('POINT(29.9187 31.2001)', 4326));
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'PPE-GLOVES-NITRILE-M')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'PPE-GLOVES-NITRILE-M', N'Nitrile Gloves Medium', 3.7500, 12000, 2, N'[0.12,0.22,0.31]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Cairo Wholesale Co';

    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'PACK-BOX-40CM', N'Corrugated Shipping Box 40cm', 1.1500, 5000, 4, N'[0.09,0.18,0.44]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Alexandria Industrial Supply';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierQualityScores)
BEGIN
    INSERT INTO dbo.SupplierQualityScores
        (SupplierID, QualityScore, ReviewCount, AverageRating, OnTimeDeliveryRate, DefectRate, ComputedAt)
    SELECT SupplierID, ReliabilityScore, 100, 4.60, 0.9700, 0.0100, SYSUTCDATETIME()
    FROM dbo.SupplierProfiles;
END
GO
