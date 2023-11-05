/*-------------------------------------------------------------------
-- 4 - sp_whoisactive
-- 
-- Summary: 
-- https://whoisactive.com/
-- 
-------------------------------------------------------------------*/






-----
-- Andy's SSMS keyboard shortcuts:
-- Ctrl-7:
EXEC sp_whoisactive @get_plans = 2, @get_transaction_info = 1, @get_task_info = 2, @get_avg_time = 1, @get_outer_command= 1

-- Ctrl-0:
EXEC sp_whoisactive @get_plans = 2, @get_transaction_info = 1, @get_task_info = 2, @get_avg_time = 1, @get_outer_command= 1, @delta_interval = 10








-----
-- @get_transaction_info = 1	-- BIT
-- 
-- Enables pulling transaction log write info and transaction duration  

-----
-- @get_task_info = 2	-- TINYINT
-- 
-- Get information on active tasks, based on three interest levels  
--    * Level 0 does not pull any task-related information  
--    * Level 1 is a lightweight mode that pulls the top non-CXPACKET wait, giving preference to blockers  
--    * Level 2 pulls all available task-based metrics, including:   
--            number of active tasks, current wait stats, physical I/O, context switches, and blocker information  
-- writes = # of data pages; derived from sys.dm_exec_sessions and sys.dm_exec_requests
-- physical_io = I/O operations; derived from pending_io_count.sys.dm_os_tasks








-----
-- Review details found in tran_log_writes 
--
-- Format: {database name} {number of log records written} ({size of log records} kB)
--
-- Execute 
--    1. 4a - tran_log_writes.sql
--    2. command below
EXEC sp_whoisactive @get_transaction_info = 1, @get_task_info = 2
GO








-----
-- Demo Variant: time permitting, execute 
--    1. 3 - sys.dm_io_virtual_file_stats-delta-v2.sql
--    2. 4a - tran_log_writes.sql
--    3. command below
EXEC sp_whoisactive @get_transaction_info = 1, @get_task_info = 2
GO








-----
-- Dirty Pages & Clean Pages
USE Sandbox
GO
SELECT
	objects.name,
	COUNT(1) AS NumPagesInBuffer,
	COUNT(1) * 8.0 AS BufferSpaceUsed_KB,
    SUM(
		CASE dm_os_buffer_descriptors.is_modified 
			WHEN 1 
			THEN 1 
			ELSE 0
		END
	) AS DirtyPages,
    SUM(
		CASE dm_os_buffer_descriptors.is_modified 
			WHEN 1 
			THEN 0 
			ELSE 1
		END
	) AS CleanPages,
    SUM(
		CASE dm_os_buffer_descriptors.is_modified 
			WHEN 1 
			THEN 1 
			ELSE 0
		END
	) * 8.0 AS DirtyPages_KB,
    SUM(
		CASE dm_os_buffer_descriptors.is_modified 
			WHEN 1 
			THEN 0 
			ELSE 1
		END
	) * 8.0 AS CleanPages_KB
FROM sys.dm_os_buffer_descriptors
INNER JOIN sys.allocation_units 
	ON allocation_units.allocation_unit_id = dm_os_buffer_descriptors.allocation_unit_id
INNER JOIN sys.partitions 
	ON (
		allocation_units.container_id = partitions.hobt_id AND type IN (1,3)
		OR 
		allocation_units.container_id = partitions.partition_id AND type IN (2)
	)
INNER JOIN sys.objects 
	ON partitions.object_id = objects.object_id
WHERE allocation_units.type IN (1,2,3)
	AND objects.type = 'U'
	AND dm_os_buffer_descriptors.database_id = DB_ID(N'Sandbox')
	AND objects.name = 'UpdateTest'
GROUP BY objects.schema_id, objects.name, objects.type_desc







-----
-- Demo Variant 2: time permitting, execute
-- (hope lazy writer hasn't caught up)
--    1. 3 - sys.dm_io_virtual_file_stats-delta-v2.sql
--    2. command below
--    3. re-run sys.dm_os_buffer_descriptors query above
CHECKPOINT
GO
