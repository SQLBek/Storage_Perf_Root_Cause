/*-------------------------------------------------------------------
-- 3 - sys.dm_io_virtual_file_stats-delta-v2.sql
-- 
-- Summary: 
-- Capture sys.dm_io_virtual_file_stats and calculate deltas
-- over a period of time.
--
-- Important Usage Note:
-- Be sure to change the two database filters (search Optional)
-- and the time duration (or event) to occur between each
-- sample (search CHANGE ME)
-- 
--
-- Credits:
-- Adaptation of Anthony Nocentino's sys.dm_io_virtual_file_stats 
-- diagnostic script and Paul Randal's delta methodology to capture 
-- data over a period of time.
-- Used w. Permission 
--
-- https://www.nocentino.com/posts/2021-10-06-sql-server-file-latency/
-- https://www.sqlskills.com/blogs/paul/capturing-io-latencies-period-time/
--
-------------------------------------------------------------------*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
GO
IF OBJECT_ID('tempdb.dbo.#tmpVirtFileStats1','U') IS NOT NULL 
	DROP TABLE #tmpVirtFileStats1

IF OBJECT_ID('tempdb.dbo.#tmpVirtFileStats2','U') IS NOT NULL 
	DROP TABLE #tmpVirtFileStats2
GO

SELECT 
	dm_io_virtual_file_stats.database_id,
	dm_io_virtual_file_stats.file_id,
	dm_io_virtual_file_stats.num_of_reads,
	dm_io_virtual_file_stats.num_of_bytes_read,
	dm_io_virtual_file_stats.io_stall_read_ms,
	dm_io_virtual_file_stats.num_of_writes,
	dm_io_virtual_file_stats.num_of_bytes_written,
	dm_io_virtual_file_stats.io_stall_write_ms,
	dm_io_virtual_file_stats.io_stall,
	dm_io_virtual_file_stats.file_handle,
	master_files.type_desc,
	master_files.physical_name
INTO #tmpVirtFileStats1
FROM sys.dm_io_virtual_file_stats(NULL, NULL)
INNER JOIN sys.master_files
	ON dm_io_virtual_file_stats.database_id = master_files.database_id
	AND dm_io_virtual_file_stats.file_id = master_files.file_id
-- OPTIONAL: Filter
WHERE master_files.database_id IN (
	DB_ID('AutoDealershipDemo'),
	DB_ID('CookbookDemo'),
	DB_ID('Doghouse'),
	DB_ID('Sandbox')
)
GO

--------------------------------------------------------------------
-- CHANGE ME
-- 
-- Change the below to either capture all activity for a preset 
-- duration 
-- OR
-- activity around the execution of a procedure.  Note this will
-- capture ALL activity so is only useful in isolation
-- 
--------------------------------------------------------------------
--
WAITFOR DELAY '00:00:10';	-- 10 seconds
GO
--
-- Sample workload
-- Read Only
--EXEC DogHouse.workload.SelAll_InventoryFlat
--GO 
---- DML
--EXEC DogHouse.workload.Set_InventoryFlat_MSRP
--GO 

----------------------------------
-- END CHANGE ME
----------------------------------

SELECT 
	dm_io_virtual_file_stats.database_id,
	dm_io_virtual_file_stats.file_id,
	dm_io_virtual_file_stats.num_of_reads,
	dm_io_virtual_file_stats.num_of_bytes_read,
	dm_io_virtual_file_stats.io_stall_read_ms,
	dm_io_virtual_file_stats.num_of_writes,
	dm_io_virtual_file_stats.num_of_bytes_written,
	dm_io_virtual_file_stats.io_stall_write_ms,
	dm_io_virtual_file_stats.io_stall,
	dm_io_virtual_file_stats.file_handle,
	master_files.name,
	master_files.type_desc,
	master_files.physical_name
INTO #tmpVirtFileStats2
FROM sys.dm_io_virtual_file_stats(NULL, NULL)
INNER JOIN sys.master_files
	ON dm_io_virtual_file_stats.database_id = master_files.database_id
	AND dm_io_virtual_file_stats.file_id = master_files.file_id
-- OPTIONAL: Filter
WHERE master_files.database_id IN (		
	DB_ID('AutoDealershipDemo'),
	DB_ID('CookbookDemo'),
	DB_ID('Doghouse'),
	DB_ID('Sandbox')
)
GO


WITH IOStatsDelta_CTE
AS (
	SELECT
		-- Include files that may not have been present in the first data capture
		#tmpVirtFileStats2.database_id,
		#tmpVirtFileStats2.file_id,
		#tmpVirtFileStats2.num_of_reads,
		#tmpVirtFileStats2.io_stall_read_ms,
		#tmpVirtFileStats2.num_of_writes,
		#tmpVirtFileStats2.io_stall_write_ms,
		#tmpVirtFileStats2.io_stall,
		#tmpVirtFileStats2.num_of_bytes_read,
		#tmpVirtFileStats2.num_of_bytes_written,
		#tmpVirtFileStats2.name,
		#tmpVirtFileStats2.type_desc,
		#tmpVirtFileStats2.physical_name
	FROM #tmpVirtFileStats2
	LEFT OUTER JOIN #tmpVirtFileStats1
		ON #tmpVirtFileStats2.file_handle = #tmpVirtFileStats1.file_handle
	WHERE #tmpVirtFileStats1.file_handle IS NULL
	
	UNION
	
	SELECT
		-- Diff of latencies in both snapshots
		#tmpVirtFileStats2.database_id,
		#tmpVirtFileStats2.file_id,
		#tmpVirtFileStats2.num_of_reads - #tmpVirtFileStats1.num_of_reads AS num_of_reads,
		#tmpVirtFileStats2.io_stall_read_ms - #tmpVirtFileStats1.io_stall_read_ms AS io_stall_read_ms,
		#tmpVirtFileStats2.num_of_writes - #tmpVirtFileStats1.num_of_writes AS num_of_writes,
		#tmpVirtFileStats2.io_stall_write_ms - #tmpVirtFileStats1.io_stall_write_ms AS io_stall_write_ms,
		#tmpVirtFileStats2.io_stall - #tmpVirtFileStats1.io_stall AS io_stall,
		#tmpVirtFileStats2.num_of_bytes_read - #tmpVirtFileStats1.num_of_bytes_read AS num_of_bytes_read,
		#tmpVirtFileStats2.num_of_bytes_written - #tmpVirtFileStats1.num_of_bytes_written AS num_of_bytes_written,
		#tmpVirtFileStats2.name,
		#tmpVirtFileStats2.type_desc,
		#tmpVirtFileStats2.physical_name
	FROM #tmpVirtFileStats2
	LEFT OUTER JOIN #tmpVirtFileStats1
		ON #tmpVirtFileStats2.file_handle = #tmpVirtFileStats1.file_handle
	WHERE #tmpVirtFileStats1.file_handle IS NOT NULL
	)
SELECT 
	DB_NAME(database_id) AS DBName,
	[name] AS FileName,
	type_desc AS FileType,
	num_of_reads AS NumReads, -- Number of reads issued on the file.
	num_of_writes AS NumWrites, -- Number of writes made on this file.
	num_of_bytes_read AS ReadBytes, -- Total number of bytes read on this file.
	num_of_bytes_written AS WriteBytes, -- Total number of bytes written to the file.
	num_of_bytes_read + num_of_bytes_written AS TotalBytes, -- Total number of bytes reads and writes the file.
	-- Calculate the percentage of bytes read or written to the file
	CASE WHEN
		(num_of_bytes_read + num_of_bytes_written) = 0
			THEN 0
		ELSE num_of_bytes_read * 100 / (num_of_bytes_read + num_of_bytes_written)
	END AS PercentBytesRead,
	CASE WHEN
		(num_of_bytes_read + num_of_bytes_written) = 0
			THEN 0
		ELSE num_of_bytes_written * 100 / (num_of_bytes_read + num_of_bytes_written) 
	END AS PercentBytesWrite,
	-- Calculate the average read latency and the average read IO size 
	CASE 
		WHEN num_of_reads = 0
			THEN 0
		ELSE io_stall_read_ms / num_of_reads
		END AS AvgReadLatency_ms,
	CASE 
		WHEN num_of_reads = 0
			THEN 0
		ELSE (num_of_bytes_read / num_of_reads) / 1024
		END AS AvgReadSize_KB,
	-- Calculate the average write latency and the average write IO size
	CASE 
		WHEN num_of_writes = 0
			THEN 0
		ELSE io_stall_write_ms / num_of_writes
		END AS AvgWriteLatency_ms,
	CASE 
		WHEN num_of_writes = 0
			THEN 0
		ELSE (num_of_bytes_written / num_of_writes) / 1024
		END AS AvgWriteSize_KB,
	-- Calculate the average total latency and the average IO size
	CASE 
		WHEN num_of_reads + num_of_writes = 0
			THEN 0
		ELSE io_stall / (num_of_reads + num_of_writes)
		END AS AvgLatency_ms,
	CASE 
		WHEN num_of_reads + num_of_writes = 0
			THEN 0
		ELSE (num_of_bytes_read + num_of_bytes_written) / (num_of_reads + num_of_writes) / 1024
		END AS AvgIOSize_KB,
	physical_name AS PhysicalFileName	-- The physical file name
FROM IOStatsDelta_CTE 
ORDER BY
	DBName, type_desc DESC
	--  AvgLatency_(ms) DESC
	--  AvgReadLatency_(ms)
	--  AvgWriteLatency_(ms)
