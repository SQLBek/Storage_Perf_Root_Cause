/*-------------------------------------------------------------------
-- 0a - Workload.sql
--
-- Run this at start of demo segment 
-------------------------------------------------------------------*/
SET NOCOUNT ON
GO

EXEC Doghouse.dbo.sp_ExecuteRandomProc

EXEC CookbookDemo.dbo.sp_ExecuteRandomProc

EXEC AutoDealershipDemo.dbo.sp_ExecuteRandomProc
GO 5

/*
-- Read Only
EXEC DogHouse.workload.SelAll_InventoryFlat
GO 15

-- DML
EXEC DogHouse.workload.Set_InventoryFlat_MSRP
GO 25
*/

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

/*
USE Doghouse
GO
CHECKPOINT
GO
EXEC Doghouse.workload.Add_InventoryFlat_MSRP
GO 3
EXEC Doghouse.workload.SelAll_InventoryFlat
GO 10
EXEC Doghouse.workload.Add_InventoryFlat_TrueCost
GO 3
EXEC Doghouse.workload.SelAll_InventoryFlat
GO 10
EXEC Doghouse.workload.Add_InventoryFlat_InvoicePrice
GO 3
EXEC Doghouse.workload.SelAll_InventoryFlat
GO 10
EXEC Doghouse.workload.Set_InventoryFlat_MSRP
GO 3
EXEC Doghouse.workload.SelAll_InventoryFlat
GO 10


SET STATISTICS IO ON

EXEC Doghouse.workload.SelAll_InventoryFlat
GO 
DBCC DROPCLEANBUFFERS
GO
EXEC Doghouse.workload.Set_InventoryFlat_MSRP
GO 

*/