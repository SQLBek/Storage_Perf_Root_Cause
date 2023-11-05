USE Sandbox
GO
/*
-----------
-- SETUP
-----------
IF OBJECT_ID('demo.UpdateTest','U') IS NOT NULL 
	DROP TABLE demo.UpdateTest
GO
CREATE TABLE demo.UpdateTest (
	RecID INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
	MyValue VARCHAR(250),
	MyGUID UNIQUEIDENTIFIER
);

-- Generate 250,000 records
INSERT INTO demo.UpdateTest (
	MyValue, MyGUID
)
SELECT TOP 250000
	t1.name,
	NEWID()
FROM sys.objects t1
CROSS APPLY sys.columns t2
CROSS APPLY sys.indexes t3
GO
*/

-----------
-- END 
-----------




-----
-- Code to generate a tran_log_writes entry for sp_whoisactive
BEGIN TRANSACTION

	UPDATE demo.UpdateTest
	SET MyGUID = NEWID();

	WAITFOR DELAY '00:00:15';

COMMIT TRANSACTION
GO
