CREATE TABLE [dim].[Players] (
    [PlayerID]  INT          IDENTITY (1, 1) NOT NULL,
    [SourceID]  TINYINT      NOT NULL,
    [LastName]  VARCHAR (50) NOT NULL,
    [FirstName] VARCHAR (30) NULL,
    [SelfFlag]  BIT          CONSTRAINT [DF_Players_SelfFlag] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Players] PRIMARY KEY CLUSTERED ([PlayerID] ASC),
    CONSTRAINT [FK_Players_SourceID] FOREIGN KEY ([SourceID]) REFERENCES [dim].[Sources] ([SourceID]),
    CONSTRAINT [UC_Name] UNIQUE NONCLUSTERED ([SourceID] ASC, [LastName] ASC, [FirstName] ASC)
);

