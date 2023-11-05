/*-------------------------------------------------------------------
-- 5 - Deep Dive Internals.sql
-- 
-- Summary: 
-- Deep dive into SQL Server Internals with SysInternals 
-- Process Monitor & fn_dblog
--
-- Process Monitor Filters:
-- Path - Starts with - E:\SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Sandbox
-- Process Name - Is - sqlservr.exe
-- 
-- https://learn.microsoft.com/en-us/sysinternals/
--
-------------------------------------------------------------------*/
USE Sandbox
GO


-----
-- Clear everything out then Start Capture in ProcMon
DBCC DROPCLEANBUFFERS
CHECKPOINT
DBCC FREEPROCCACHE
GO
SET STATISTICS IO ON
GO


SELECT TOP 10000 * FROM Sandbox.demo.UpdateTest
GO




-----
-- Update 1 single record
-- Clear everything out then Start Capture in ProcMon
DBCC DROPCLEANBUFFERS
CHECKPOINT
DBCC FREEPROCCACHE
GO


-----
-- Start
BEGIN TRANSACTION

UPDATE Sandbox.demo.UpdateTest
SET MyValue = NEWID()
FROM Sandbox.demo.UpdateTest
WHERE RecID = 1

COMMIT TRANSACTION

-- Read from the Transaction Log. LSN = [VLF ID:Log Block ID:Log Record ID]
SELECT 
	[Transaction ID], [Current LSN], Operation, Context, AllocUnitName, [Transaction Name], Description,
	CAST(CAST([RowLog Contents 0] AS VARBINARY(MAX)) AS VARCHAR(MAX)) AS [RowLog Contents 0-Translated],
	CAST(CAST([RowLog Contents 1] AS VARBINARY(MAX)) AS VARCHAR(MAX)) AS [RowLog Contents 1-Translated] 
FROM fn_dblog(NULL, NULL)
-- End
-----








-----
-- Update 99 records
-- Clear everything out then Start Capture in ProcMon
DBCC DROPCLEANBUFFERS
CHECKPOINT
DBCC FREEPROCCACHE
GO


-----
-- Start
BEGIN TRANSACTION

UPDATE Sandbox.demo.UpdateTest
SET MyValue = NEWID()
FROM Sandbox.demo.UpdateTest
WHERE RecID < 100

COMMIT TRANSACTION

-- Read from the Transaction Log. LSN = [VLF ID:Log Block ID:Log Record ID]
SELECT 
	[Transaction ID], [Current LSN], Operation, Context, AllocUnitName, [Transaction Name], Description,
	CAST(CAST([RowLog Contents 0] AS VARBINARY(MAX)) AS VARCHAR(MAX)) AS [RowLog Contents 0-Translated],
	CAST(CAST([RowLog Contents 1] AS VARBINARY(MAX)) AS VARCHAR(MAX)) AS [RowLog Contents 1-Translated] 
FROM fn_dblog(NULL, NULL)
-- End
-----








-----
-- Update 999 records
-- Clear everything out then Start Capture in ProcMon
DBCC DROPCLEANBUFFERS
CHECKPOINT
DBCC FREEPROCCACHE
GO


-----
-- Start
BEGIN TRANSACTION

UPDATE Sandbox.demo.UpdateTest
SET MyValue = NEWID()
FROM Sandbox.demo.UpdateTest
WHERE RecID < 1000

COMMIT TRANSACTION

-- Read from the Transaction Log. LSN = [VLF ID:Log Block ID:Log Record ID]
SELECT 
	[Transaction ID], [Current LSN], Operation, Context, AllocUnitName, [Transaction Name], Description,
	CAST(CAST([RowLog Contents 0] AS VARBINARY(MAX)) AS VARCHAR(MAX)) AS [RowLog Contents 0-Translated],
	CAST(CAST([RowLog Contents 1] AS VARBINARY(MAX)) AS VARCHAR(MAX)) AS [RowLog Contents 1-Translated] 
FROM fn_dblog(NULL, NULL)
-- End
-----



