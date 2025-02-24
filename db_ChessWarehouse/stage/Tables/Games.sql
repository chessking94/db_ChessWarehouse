CREATE TABLE [stage].[Games] (
    [Errors]            VARCHAR (100) NULL,
    [SourceName]        VARCHAR (15)  NULL,
    [SiteName]          VARCHAR (26)  NULL,
    [SiteGameID]        VARCHAR (15)  COLLATE Latin1_General_CS_AS NULL,
    [WhiteLast]         VARCHAR (50)  NULL,
    [WhiteFirst]        VARCHAR (30)  NULL,
    [WhitePlayerID]     INT           NULL,
    [BlackLast]         VARCHAR (50)  NULL,
    [BlackFirst]        VARCHAR (30)  NULL,
    [BlackPlayerID]     INT           NULL,
    [WhiteElo]          VARCHAR (4)   NULL,
    [BlackElo]          VARCHAR (4)   NULL,
    [TimeControlDetail] VARCHAR (15)  NULL,
    [ECO_Code]          CHAR (3)      NULL,
    [GameDate]          DATE          NULL,
    [GameTime]          TIME (0)      NULL,
    [EventName]         VARCHAR (100) NULL,
    [RoundNum]          VARCHAR (7)   NULL,
    [Result]            CHAR (3)      NULL,
    [EventRated]        BIT           NULL,
    [FileID]            INT           NULL
);

