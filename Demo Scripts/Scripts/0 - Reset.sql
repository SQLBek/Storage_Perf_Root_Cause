/*-------------------------------------------------------------------
-- 0 - Reset.sql
-- 
-------------------------------------------------------------------*/
--USE Sandbox
--GO
--IF OBJECT_ID('demo.UpdateTest','U') IS NOT NULL 
--	DROP TABLE demo.UpdateTest
--GO
--CREATE TABLE demo.UpdateTest (
--	RecID INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
--	MyValue VARCHAR(250),
--	MyGUID UNIQUEIDENTIFIER
--);

---- Generate 250,000 records
--INSERT INTO demo.UpdateTest (
--	MyValue, MyGUID
--)
--SELECT TOP 250000
--	t1.name,
--	NEWID()
--FROM sys.objects t1
--CROSS APPLY sys.columns t2
--CROSS APPLY sys.indexes t3
--GO


-----------------------------
-- Run a bunch of workload 
-- to seed DMVs
-- ~5 min
-- Use extra query windows to speed things up
-----------------------------
SET NOCOUNT ON
GO

EXEC Doghouse.dbo.sp_ExecuteRandomProc
GO 50

EXEC CookbookDemo.dbo.sp_ExecuteRandomProc
GO 5

EXEC AutoDealershipDemo.dbo.sp_ExecuteRandomProc
GO 5

-- Read Only
EXEC DogHouse.workload.SelAll_InventoryFlat
GO 15

-- DML
EXEC DogHouse.workload.Set_InventoryFlat_MSRP
GO 25