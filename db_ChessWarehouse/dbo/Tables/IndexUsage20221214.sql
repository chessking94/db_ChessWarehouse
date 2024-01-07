CREATE TABLE [dbo].[IndexUsage20221214] (
    [Table_Name]   NVARCHAR (128) NULL,
    [Index_Name]   [sysname]      NULL,
    [Index_Type]   NVARCHAR (60)  COLLATE Latin1_General_CI_AS_KS_WS NULL,
    [IndexSizeKB]  BIGINT         NULL,
    [NumOfSeeks]   BIGINT         NOT NULL,
    [NumOfScans]   BIGINT         NOT NULL,
    [NumOfLookups] BIGINT         NOT NULL,
    [NumOfUpdates] BIGINT         NOT NULL,
    [LastSeek]     DATETIME       NULL,
    [LastScan]     DATETIME       NULL,
    [LastLookup]   DATETIME       NULL,
    [LastUpdate]   DATETIME       NULL
);

