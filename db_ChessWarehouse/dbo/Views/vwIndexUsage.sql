CREATE VIEW vwIndexUsage

AS

SELECT
OBJECT_NAME(ix.object_id) AS Table_Name,
ix.name AS Index_Name,
ix.type_desc AS Index_Type,
SUM(ps.[used_page_count]) * 8 AS IndexSizeKB,
ixus.user_seeks AS NumOfSeeks,
ixus.user_scans AS NumOfScans,
ixus.user_lookups AS NumOfLookups,
ixus.user_updates AS NumOfUpdates,
ixus.last_user_seek AS LastSeek,
ixus.last_user_scan AS LastScan,
ixus.last_user_lookup AS LastLookup,
ixus.last_user_update AS LastUpdate

FROM sys.indexes ix
JOIN sys.dm_db_index_usage_stats ixus ON
	ix.index_id = ixus.index_id 
	AND ixus.object_id = ix.object_id
JOIN sys.dm_db_partition_stats ps ON
	ps.object_id = ix.object_id

WHERE OBJECTPROPERTY(ix.object_id, 'IsUserTable') = 1

GROUP BY
OBJECT_NAME(ix.object_id),
ix.name,
ix.type_desc,
ixus.user_seeks,
ixus.user_scans,
ixus.user_lookups,
ixus.user_updates,
ixus.last_user_seek,
ixus.last_user_scan,
ixus.last_user_lookup,
ixus.last_user_update