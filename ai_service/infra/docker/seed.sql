IF DB_ID(N'SalaselAiService') IS NULL
BEGIN
    CREATE DATABASE SalaselAiService;
END
GO

USE SalaselAiService;
GO

-- Spatial index on SupplierProfiles.Location requires QUOTED_IDENTIFIER ON
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- Suppliers
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierProfiles WHERE CompanyName = N'Cairo Wholesale Co')
BEGIN
    INSERT INTO dbo.SupplierProfiles
        (CompanyName, ReliabilityScore, PaymentTerms, IsActiveForRouting, Latitude, Longitude, Location)
    VALUES
        (N'Cairo Wholesale Co', 94.50, N'Net 30', 1, 30.0444, 31.2357, geography::STGeomFromText('POINT(31.2357 30.0444)', 4326));
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierProfiles WHERE CompanyName = N'Alexandria Industrial Supply')
BEGIN
    INSERT INTO dbo.SupplierProfiles
        (CompanyName, ReliabilityScore, PaymentTerms, IsActiveForRouting, Latitude, Longitude, Location)
    VALUES
        (N'Alexandria Industrial Supply', 88.25, N'Net 15', 1, 31.2001, 29.9187, geography::STGeomFromText('POINT(29.9187 31.2001)', 4326));
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierProfiles WHERE CompanyName = N'Giza Distribution Hub')
BEGIN
    INSERT INTO dbo.SupplierProfiles
        (CompanyName, ReliabilityScore, PaymentTerms, IsActiveForRouting, Latitude, Longitude, Location)
    VALUES
        (N'Giza Distribution Hub', 91.00, N'Net 30', 1, 30.0131, 31.2089, geography::STGeomFromText('POINT(31.2089 30.0131)', 4326));
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierProfiles WHERE CompanyName = N'Helwan Manufacturing Supplies')
BEGIN
    INSERT INTO dbo.SupplierProfiles
        (CompanyName, ReliabilityScore, PaymentTerms, IsActiveForRouting, Latitude, Longitude, Location)
    VALUES
        (N'Helwan Manufacturing Supplies', 84.75, N'Net 15', 1, 29.8539, 31.3335, geography::STGeomFromText('POINT(31.3335 29.8539)', 4326));
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierProfiles WHERE CompanyName = N'Sixth of October Industrial Supply')
BEGIN
    INSERT INTO dbo.SupplierProfiles
        (CompanyName, ReliabilityScore, PaymentTerms, IsActiveForRouting, Latitude, Longitude, Location)
    VALUES
        (N'Sixth of October Industrial Supply', 87.50, N'Net 30', 1, 29.9369, 30.9187, geography::STGeomFromText('POINT(30.9187 29.9369)', 4326));
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierProfiles WHERE CompanyName = N'Nasr City Office Depot')
BEGIN
    INSERT INTO dbo.SupplierProfiles
        (CompanyName, ReliabilityScore, PaymentTerms, IsActiveForRouting, Latitude, Longitude, Location)
    VALUES
        (N'Nasr City Office Depot', 90.20, N'Net 15', 1, 30.0584, 31.3306, geography::STGeomFromText('POINT(31.3306 30.0584)', 4326));
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierProfiles WHERE CompanyName = N'Mansoura Electrical Wholesale')
BEGIN
    INSERT INTO dbo.SupplierProfiles
        (CompanyName, ReliabilityScore, PaymentTerms, IsActiveForRouting, Latitude, Longitude, Location)
    VALUES
        (N'Mansoura Electrical Wholesale', 86.00, N'Net 15', 1, 31.0409, 31.3785, geography::STGeomFromText('POINT(31.3785 31.0409)', 4326));
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierProfiles WHERE CompanyName = N'Tanta Agro Supplies')
BEGIN
    INSERT INTO dbo.SupplierProfiles
        (CompanyName, ReliabilityScore, PaymentTerms, IsActiveForRouting, Latitude, Longitude, Location)
    VALUES
        (N'Tanta Agro Supplies', 82.30, N'Net 30', 1, 30.7885, 31.0019, geography::STGeomFromText('POINT(31.0019 30.7885)', 4326));
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierProfiles WHERE CompanyName = N'Port Said Maritime Logistics')
BEGIN
    INSERT INTO dbo.SupplierProfiles
        (CompanyName, ReliabilityScore, PaymentTerms, IsActiveForRouting, Latitude, Longitude, Location)
    VALUES
        (N'Port Said Maritime Logistics', 79.50, N'Net 60', 1, 31.2565, 32.2841, geography::STGeomFromText('POINT(32.2841 31.2565)', 4326));
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierProfiles WHERE CompanyName = N'Zagazig Food Packaging')
BEGIN
    INSERT INTO dbo.SupplierProfiles
        (CompanyName, ReliabilityScore, PaymentTerms, IsActiveForRouting, Latitude, Longitude, Location)
    VALUES
        (N'Zagazig Food Packaging', 83.10, N'Net 30', 1, 30.5877, 31.5020, geography::STGeomFromText('POINT(31.5020 30.5877)', 4326));
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierProfiles WHERE CompanyName = N'Damanhur Chemical & Detergent')
BEGIN
    INSERT INTO dbo.SupplierProfiles
        (CompanyName, ReliabilityScore, PaymentTerms, IsActiveForRouting, Latitude, Longitude, Location)
    VALUES
        (N'Damanhur Chemical & Detergent', 81.90, N'Net 30', 1, 31.0359, 30.4705, geography::STGeomFromText('POINT(30.4705 31.0359)', 4326));
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierProfiles WHERE CompanyName = N'Suez Canal Engineering')
BEGIN
    INSERT INTO dbo.SupplierProfiles
        (CompanyName, ReliabilityScore, PaymentTerms, IsActiveForRouting, Latitude, Longitude, Location)
    VALUES
        (N'Suez Canal Engineering', 85.60, N'Net 60', 1, 29.9668, 32.5498, geography::STGeomFromText('POINT(32.5498 29.9668)', 4326));
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierProfiles WHERE CompanyName = N'Assiut Office & Paper Co')
BEGIN
    INSERT INTO dbo.SupplierProfiles
        (CompanyName, ReliabilityScore, PaymentTerms, IsActiveForRouting, Latitude, Longitude, Location)
    VALUES
        (N'Assiut Office & Paper Co', 77.80, N'Net 30', 1, 27.1809, 31.1851, geography::STGeomFromText('POINT(31.1851 27.1809)', 4326));
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierProfiles WHERE CompanyName = N'Luxor Hospitality Supplies')
BEGIN
    INSERT INTO dbo.SupplierProfiles
        (CompanyName, ReliabilityScore, PaymentTerms, IsActiveForRouting, Latitude, Longitude, Location)
    VALUES
        (N'Luxor Hospitality Supplies', 76.40, N'Net 15', 1, 25.6872, 32.6396, geography::STGeomFromText('POINT(32.6396 25.6872)', 4326));
END
GO

-- ============================================================
-- Supplier catalogs (products)
-- ============================================================

-- PPE
IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'PPE-GLOVES-NITRILE-M')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'PPE-GLOVES-NITRILE-M', N'Nitrile Gloves Medium', N'PPE', 3.7500, 12000, 2, N'[0.12,0.22,0.31]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Cairo Wholesale Co';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'PPE-GLOVES-NITRILE-L')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'PPE-GLOVES-NITRILE-L', N'Nitrile Gloves Large', N'PPE', 4.1000, 15000, 2, N'[0.13,0.24,0.35]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Giza Distribution Hub';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'PPE-MASKS-KN95')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'PPE-MASKS-KN95', N'KN95 Respirator Masks', N'PPE', 2.4500, 30000, 2, N'[0.10,0.18,0.40]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Giza Distribution Hub';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'PPE-GOGGLES-SAFETY')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'PPE-GOGGLES-SAFETY', N'Safety Goggles', N'PPE', 1.8500, 8000, 3, N'[0.11,0.20,0.29]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Helwan Manufacturing Supplies';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'PPE-HELMET-SAFETY')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'PPE-HELMET-SAFETY', N'Safety Helmet', N'PPE', 6.5000, 4000, 5, N'[0.15,0.28,0.37]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Helwan Manufacturing Supplies';
END
GO

-- Packaging
IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'PACK-BOX-40CM')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'PACK-BOX-40CM', N'Corrugated Shipping Box 40cm', N'Packaging', 1.1500, 5000, 4, N'[0.09,0.18,0.44]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Alexandria Industrial Supply';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'PACK-BOX-50CM')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'PACK-BOX-50CM', N'Corrugated Shipping Box 50cm', N'Packaging', 1.4500, 8000, 4, N'[0.10,0.19,0.45]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Giza Distribution Hub';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'PACK-TAPE-BROWN')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'PACK-TAPE-BROWN', N'Brown Packing Tape 48mm', N'Packaging', 0.8500, 25000, 2, N'[0.08,0.16,0.42]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Port Said Maritime Logistics';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'PACK-BUBBLE-ROLL')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'PACK-BUBBLE-ROLL', N'Bubble Wrap Roll 30cm', N'Packaging', 3.2000, 6000, 3, N'[0.12,0.23,0.47]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Port Said Maritime Logistics';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'PACK-FOOD-TRAY')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'PACK-FOOD-TRAY', N'Food-Grade Tray 25cm', N'Packaging', 0.6500, 40000, 2, N'[0.07,0.15,0.43]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Zagazig Food Packaging';
END
GO

-- Office Supplies
IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'OFF-PAPER-A4')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'OFF-PAPER-A4', N'A4 Copy Paper 500 sheets', N'Office Supplies', 2.9000, 20000, 2, N'[0.14,0.26,0.33]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Assiut Office & Paper Co';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'OFF-PENS-BLUE-50')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'OFF-PENS-BLUE-50', N'Blue Ballpoint Pens (box of 50)', N'Office Supplies', 4.7500, 12000, 3, N'[0.13,0.25,0.34]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Assiut Office & Paper Co';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'OFF-FOLDERS-A4')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'OFF-FOLDERS-A4', N'A4 Poly Folders (pack of 10)', N'Office Supplies', 3.6000, 9000, 4, N'[0.11,0.21,0.32]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Nasr City Office Depot';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'OFF-STAPLER-HEAVY')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'OFF-STAPLER-HEAVY', N'Heavy-Duty Stapler', N'Office Supplies', 8.2500, 3500, 3, N'[0.16,0.29,0.36]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Nasr City Office Depot';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'OFF-NOTEBOOKS-A5')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'OFF-NOTEBOOKS-A5', N'A5 Notebooks (pack of 20)', N'Office Supplies', 6.4000, 7000, 4, N'[0.12,0.24,0.30]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Nasr City Office Depot';
END
GO

-- Cleaning Supplies
IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'CLEAN-DETERGENT-5L')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'CLEAN-DETERGENT-5L', N'Industrial Detergent 5L', N'Cleaning Supplies', 7.2500, 5000, 3, N'[0.17,0.31,0.39]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Damanhur Chemical & Detergent';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'CLEAN-SANITIZER-1L')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'CLEAN-SANITIZER-1L', N'Hand Sanitizer 1L', N'Cleaning Supplies', 3.9500, 18000, 2, N'[0.11,0.20,0.38]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Tanta Agro Supplies';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'CLEAN-WIPES-IND')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'CLEAN-WIPES-IND', N'Industrial Cleaning Wipes (pack of 50)', N'Cleaning Supplies', 5.4000, 7000, 4, N'[0.13,0.23,0.41]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Tanta Agro Supplies';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'CLEAN-DEGREASER-1L')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'CLEAN-DEGREASER-1L', N'Engine Degreaser 1L', N'Cleaning Supplies', 6.1000, 4000, 3, N'[0.15,0.27,0.40]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Damanhur Chemical & Detergent';
END
GO

-- Electrical
IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'ELEC-CABLE-2.5MM')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'ELEC-CABLE-2.5MM', N'Copper Cable 2.5mm (100m)', N'Electrical', 18.5000, 3000, 5, N'[0.19,0.34,0.48]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Mansoura Electrical Wholesale';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'ELEC-SWITCH-BOX')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'ELEC-SWITCH-BOX', N'Electrical Switch Box', N'Electrical', 2.1500, 15000, 3, N'[0.10,0.19,0.31]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Mansoura Electrical Wholesale';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'ELEC-CIRCUIT-BREAKER')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'ELEC-CIRCUIT-BREAKER', N'Circuit Breaker 16A', N'Electrical', 9.8000, 5000, 4, N'[0.16,0.30,0.44]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Mansoura Electrical Wholesale';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'ELEC-LED-TUBE-18W')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'ELEC-LED-TUBE-18W', N'LED Tube 18W', N'Electrical', 4.9000, 9000, 3, N'[0.12,0.24,0.37]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Suez Canal Engineering';
END
GO

-- Industrial Tools
IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'TOOL-DRILL-BITS-HSS')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'TOOL-DRILL-BITS-HSS', N'HSS Drill Bit Set', N'Industrial Tools', 9.9000, 4000, 5, N'[0.17,0.30,0.43]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Helwan Manufacturing Supplies';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'TOOL-TAPE-MEASURE-5M')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'TOOL-TAPE-MEASURE-5M', N'Tape Measure 5m', N'Industrial Tools', 2.3000, 10000, 2, N'[0.10,0.20,0.30]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Mansoura Electrical Wholesale';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'TOOL-HAMMER-CLUB-1KG')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'TOOL-HAMMER-CLUB-1KG', N'Club Hammer 1kg', N'Industrial Tools', 7.8000, 3000, 4, N'[0.14,0.27,0.40]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Sixth of October Industrial Supply';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'TOOL-SCREWDRIVER-6PC')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'TOOL-SCREWDRIVER-6PC', N'Screwdriver Set 6pc', N'Industrial Tools', 5.9500, 6000, 3, N'[0.13,0.26,0.38]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Sixth of October Industrial Supply';
END
GO

-- Agro Supplies
IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'AGRO-FERT-UREA-25KG')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'AGRO-FERT-UREA-25KG', N'Urea Fertilizer 25kg', N'Agro Supplies', 14.2000, 2500, 5, N'[0.18,0.33,0.46]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Tanta Agro Supplies';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'AGRO-SEED-MAIZE-5KG')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'AGRO-SEED-MAIZE-5KG', N'Maize Seeds 5kg', N'Agro Supplies', 11.5000, 1500, 4, N'[0.17,0.31,0.45]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Tanta Agro Supplies';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'AGRO-PEST-INSECT-1L')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'AGRO-PEST-INSECT-1L', N'Insecticide 1L', N'Agro Supplies', 12.7500, 2000, 5, N'[0.16,0.29,0.44]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Zagazig Food Packaging';
END
GO

-- Hospitality
IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'HOSP-TOWEL-WHITE')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'HOSP-TOWEL-WHITE', N'White Cotton Towel', N'Hospitality', 4.6000, 8000, 3, N'[0.11,0.22,0.34]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Luxor Hospitality Supplies';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'HOSP-BEDDING-TWIN')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'HOSP-BEDDING-TWIN', N'Twin Bedding Set', N'Hospitality', 18.9000, 2000, 5, N'[0.19,0.35,0.49]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Luxor Hospitality Supplies';
END
GO

-- Stationery / Storage
IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'STAT-FILE-BOX')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'STAT-FILE-BOX', N'Cardboard File Box', N'Stationery', 2.7500, 12000, 3, N'[0.09,0.19,0.35]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Nasr City Office Depot';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierCatalogs WHERE SKU = N'STORE-SHELF-WIRE')
BEGIN
    INSERT INTO dbo.SupplierCatalogs
        (SupplierID, SKU, ProductName, Category, UnitPrice, StockAvailable, DeliveryLeadTime_Days, VectorEmbedding, UpdatedAt)
    SELECT SupplierID, N'STORE-SHELF-WIRE', N'Wire Shelving Unit', N'Storage', 24.5000, 1500, 6, N'[0.20,0.36,0.50]', SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Sixth of October Industrial Supply';
END
GO

-- ============================================================
-- Supplier quality scores
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierQualityScores WHERE SupplierID = (SELECT SupplierID FROM dbo.SupplierProfiles WHERE CompanyName = N'Cairo Wholesale Co'))
BEGIN
    INSERT INTO dbo.SupplierQualityScores
        (SupplierID, QualityScore, ReviewCount, AverageRating, OnTimeDeliveryRate, DefectRate, ComputedAt)
    SELECT SupplierID, 94.50, 620, 4.68, 0.9750, 0.0080, SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Cairo Wholesale Co';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierQualityScores WHERE SupplierID = (SELECT SupplierID FROM dbo.SupplierProfiles WHERE CompanyName = N'Alexandria Industrial Supply'))
BEGIN
    INSERT INTO dbo.SupplierQualityScores
        (SupplierID, QualityScore, ReviewCount, AverageRating, OnTimeDeliveryRate, DefectRate, ComputedAt)
    SELECT SupplierID, 88.25, 340, 4.52, 0.9550, 0.0120, SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Alexandria Industrial Supply';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierQualityScores WHERE SupplierID = (SELECT SupplierID FROM dbo.SupplierProfiles WHERE CompanyName = N'Giza Distribution Hub'))
BEGIN
    INSERT INTO dbo.SupplierQualityScores
        (SupplierID, QualityScore, ReviewCount, AverageRating, OnTimeDeliveryRate, DefectRate, ComputedAt)
    SELECT SupplierID, 91.00, 500, 4.72, 0.9800, 0.0050, SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Giza Distribution Hub';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierQualityScores WHERE SupplierID = (SELECT SupplierID FROM dbo.SupplierProfiles WHERE CompanyName = N'Helwan Manufacturing Supplies'))
BEGIN
    INSERT INTO dbo.SupplierQualityScores
        (SupplierID, QualityScore, ReviewCount, AverageRating, OnTimeDeliveryRate, DefectRate, ComputedAt)
    SELECT SupplierID, 84.75, 120, 4.35, 0.9500, 0.0150, SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Helwan Manufacturing Supplies';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierQualityScores WHERE SupplierID = (SELECT SupplierID FROM dbo.SupplierProfiles WHERE CompanyName = N'Sixth of October Industrial Supply'))
BEGIN
    INSERT INTO dbo.SupplierQualityScores
        (SupplierID, QualityScore, ReviewCount, AverageRating, OnTimeDeliveryRate, DefectRate, ComputedAt)
    SELECT SupplierID, 87.50, 180, 4.48, 0.9600, 0.0120, SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Sixth of October Industrial Supply';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierQualityScores WHERE SupplierID = (SELECT SupplierID FROM dbo.SupplierProfiles WHERE CompanyName = N'Nasr City Office Depot'))
BEGIN
    INSERT INTO dbo.SupplierQualityScores
        (SupplierID, QualityScore, ReviewCount, AverageRating, OnTimeDeliveryRate, DefectRate, ComputedAt)
    SELECT SupplierID, 90.20, 320, 4.61, 0.9700, 0.0080, SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Nasr City Office Depot';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierQualityScores WHERE SupplierID = (SELECT SupplierID FROM dbo.SupplierProfiles WHERE CompanyName = N'Mansoura Electrical Wholesale'))
BEGIN
    INSERT INTO dbo.SupplierQualityScores
        (SupplierID, QualityScore, ReviewCount, AverageRating, OnTimeDeliveryRate, DefectRate, ComputedAt)
    SELECT SupplierID, 86.00, 250, 4.55, 0.9600, 0.0100, SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Mansoura Electrical Wholesale';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierQualityScores WHERE SupplierID = (SELECT SupplierID FROM dbo.SupplierProfiles WHERE CompanyName = N'Tanta Agro Supplies'))
BEGIN
    INSERT INTO dbo.SupplierQualityScores
        (SupplierID, QualityScore, ReviewCount, AverageRating, OnTimeDeliveryRate, DefectRate, ComputedAt)
    SELECT SupplierID, 82.30, 15, 4.80, 0.9400, 0.0180, SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Tanta Agro Supplies';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierQualityScores WHERE SupplierID = (SELECT SupplierID FROM dbo.SupplierProfiles WHERE CompanyName = N'Port Said Maritime Logistics'))
BEGIN
    INSERT INTO dbo.SupplierQualityScores
        (SupplierID, QualityScore, ReviewCount, AverageRating, OnTimeDeliveryRate, DefectRate, ComputedAt)
    SELECT SupplierID, 79.50, 40, 4.10, 0.9200, 0.0200, SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Port Said Maritime Logistics';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierQualityScores WHERE SupplierID = (SELECT SupplierID FROM dbo.SupplierProfiles WHERE CompanyName = N'Zagazig Food Packaging'))
BEGIN
    INSERT INTO dbo.SupplierQualityScores
        (SupplierID, QualityScore, ReviewCount, AverageRating, OnTimeDeliveryRate, DefectRate, ComputedAt)
    SELECT SupplierID, 83.10, 90, 4.28, 0.9400, 0.0160, SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Zagazig Food Packaging';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierQualityScores WHERE SupplierID = (SELECT SupplierID FROM dbo.SupplierProfiles WHERE CompanyName = N'Damanhur Chemical & Detergent'))
BEGIN
    INSERT INTO dbo.SupplierQualityScores
        (SupplierID, QualityScore, ReviewCount, AverageRating, OnTimeDeliveryRate, DefectRate, ComputedAt)
    SELECT SupplierID, 81.90, 210, 4.40, 0.9500, 0.0130, SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Damanhur Chemical & Detergent';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierQualityScores WHERE SupplierID = (SELECT SupplierID FROM dbo.SupplierProfiles WHERE CompanyName = N'Suez Canal Engineering'))
BEGIN
    INSERT INTO dbo.SupplierQualityScores
        (SupplierID, QualityScore, ReviewCount, AverageRating, OnTimeDeliveryRate, DefectRate, ComputedAt)
    SELECT SupplierID, 85.60, 150, 4.42, 0.9500, 0.0140, SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Suez Canal Engineering';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierQualityScores WHERE SupplierID = (SELECT SupplierID FROM dbo.SupplierProfiles WHERE CompanyName = N'Assiut Office & Paper Co'))
BEGIN
    INSERT INTO dbo.SupplierQualityScores
        (SupplierID, QualityScore, ReviewCount, AverageRating, OnTimeDeliveryRate, DefectRate, ComputedAt)
    SELECT SupplierID, 77.80, 700, 4.65, 0.9700, 0.0080, SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Assiut Office & Paper Co';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SupplierQualityScores WHERE SupplierID = (SELECT SupplierID FROM dbo.SupplierProfiles WHERE CompanyName = N'Luxor Hospitality Supplies'))
BEGIN
    INSERT INTO dbo.SupplierQualityScores
        (SupplierID, QualityScore, ReviewCount, AverageRating, OnTimeDeliveryRate, DefectRate, ComputedAt)
    SELECT SupplierID, 76.40, 25, 4.55, 0.9100, 0.0220, SYSUTCDATETIME()
    FROM dbo.SupplierProfiles
    WHERE CompanyName = N'Luxor Hospitality Supplies';
END
GO
