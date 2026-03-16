CREATE VIEW [dbo].[vwConstraints]

AS

SELECT
	SCHEMA_NAME(t.schema_id) + '.' + t.[name] AS [table_view]
	,CASE
		WHEN t.[type] = 'U' THEN 'Table'
		WHEN t.[type] = 'V' THEN 'View'
	END AS [object_type]
	,CASE
		WHEN c.[type] = 'PK' THEN 'Primary key'
		WHEN c.[type] = 'UQ' THEN 'Unique constraint'
		WHEN i.[type] = 1 THEN 'Unique clustered index'
		WHEN i.type = 2 THEN 'Unique index'
	END AS [constraint_type]
	,ISNULL(c.[name], i.[name]) AS [constraint_name]
	,SUBSTRING(d.column_names, 1, LEN(d.column_names) - 1) AS [details]

FROM sys.objects AS t
INNER JOIN sys.indexes AS i ON t.object_id = i.object_id
	AND i.is_unique = 1
LEFT JOIN sys.key_constraints AS c ON i.object_id = c.parent_object_id
	AND	i.index_id = c.unique_index_id
CROSS APPLY (
	SELECT col.[name] + ', '
	FROM sys.index_columns AS ic
	INNER JOIN sys.columns AS col ON ic.object_id = col.object_id
		AND ic.column_id = col.column_id
	WHERE ic.object_id = t.object_id
	AND ic.index_id = i.index_id
	ORDER BY col.column_id FOR XML PATH ('')
) AS d (column_names)
WHERE t.is_ms_shipped <> 1


UNION ALL


SELECT
	SCHEMA_NAME(fk_tab.schema_id) + '.' + fk_tab.name AS foreign_table
	,'Table'
	,'Foreign key'
	,fk.name AS fk_constraint_name
	,SCHEMA_NAME(pk_tab.schema_id) + '.' + pk_tab.name

FROM sys.foreign_keys AS fk
INNER JOIN sys.tables AS fk_tab ON fk_tab.object_id = fk.parent_object_id
INNER JOIN sys.tables AS pk_tab ON pk_tab.object_id = fk.referenced_object_id
INNER JOIN sys.foreign_key_columns AS fk_cols ON fk_cols.constraint_object_id = fk.object_id


UNION ALL


SELECT
	SCHEMA_NAME(t.schema_id) + '.' + t.[name]
	,'Table'
	,'Check constraint'
	,con.[name] AS constraint_name
	,con.[definition]

FROM sys.check_constraints AS con
INNER JOIN sys.objects AS t ON con.parent_object_id = t.object_id


UNION ALL


SELECT
	SCHEMA_NAME(t.schema_id) + '.' + t.[name]
	,'Table'
	,'Default constraint'
	,con.[name]
	,col.[name] + ' = ' + con.[definition]

FROM sys.default_constraints AS con
INNER JOIN sys.objects AS t ON con.parent_object_id = t.object_id
INNER JOIN sys.all_columns AS col ON con.parent_column_id = col.column_id
	AND con.parent_object_id = col.object_id
