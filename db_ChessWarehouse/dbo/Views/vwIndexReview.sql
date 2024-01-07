


CREATE VIEW [dbo].[vwIndexReview]

AS

--Query taken from https://www.sqlshack.com/how-to-identify-and-resolve-sql-server-index-fragmentation/

SELECT
s.name AS 'Schema_Name',
t.name AS 'Table_Name',
i.name AS 'Index_Name',
ddips.avg_fragmentation_in_percent,
ddips.page_count

FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS ddips
JOIN sys.tables t ON t.object_id = ddips.object_id
JOIN sys.schemas s ON t.schema_id = S.schema_id
JOIN sys.indexes i ON i.object_id = DDIPS.object_id AND ddips.index_id = i.index_id

WHERE ddips.database_id = DB_ID()
AND i.name IS NOT NULL
AND ddips.avg_fragmentation_in_percent > 0

