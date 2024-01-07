CREATE TABLE [dim].[Engines] (
    [EngineID]   TINYINT      IDENTITY (1, 1) NOT NULL,
    [EngineName] VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_Engines] PRIMARY KEY CLUSTERED ([EngineID] ASC),
    CONSTRAINT [UC_Engines_EngineName] UNIQUE NONCLUSTERED ([EngineName] ASC)
);

