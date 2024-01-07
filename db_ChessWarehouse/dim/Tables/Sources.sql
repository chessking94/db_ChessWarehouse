CREATE TABLE [dim].[Sources] (
    [SourceID]   TINYINT      IDENTITY (1, 1) NOT NULL,
    [SourceName] VARCHAR (15) NOT NULL,
    CONSTRAINT [PK_Source] PRIMARY KEY CLUSTERED ([SourceID] ASC),
    CONSTRAINT [UC_Sources_SourceName] UNIQUE NONCLUSTERED ([SourceName] ASC)
);

