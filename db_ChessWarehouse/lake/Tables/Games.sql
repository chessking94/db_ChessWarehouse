CREATE TABLE [lake].[Games] (
    [GameID]              INT            IDENTITY (1, 1) NOT NULL,
    [DateAdded]           DATETIME       CONSTRAINT [DF_LGames_DateAdded] DEFAULT (getdate()) NOT NULL,
    [SourceID]            TINYINT        NOT NULL,
    [SiteID]              TINYINT        NULL,
    [SiteGameID]          VARCHAR (15)   COLLATE Latin1_General_CS_AS NOT NULL,
    [WhitePlayerID]       INT            NOT NULL,
    [BlackPlayerID]       INT            NOT NULL,
    [WhiteElo]            SMALLINT       NULL,
    [BlackElo]            SMALLINT       NULL,
    [TimeControlDetailID] SMALLINT       NOT NULL,
    [ECOID]               SMALLINT       NOT NULL,
    [GameDate]            DATE           NOT NULL,
    [GameTime]            TIME (0)       NULL,
    [EventID]             INT            NOT NULL,
    [RoundNum]            TINYINT        NULL,
    [Result]              DECIMAL (2, 1) NOT NULL,
    [FileID]              INT            NOT NULL,
    [WhiteBerserk]        BIT            CONSTRAINT [DF_LGames_WhiteBerserk] DEFAULT ((0)) NOT NULL,
    [BlackBerserk]        BIT            CONSTRAINT [DF_LGames_BlackBerserk] DEFAULT ((0)) NOT NULL,
    [AnalysisStatusID]    TINYINT        NOT NULL,
    [AnalysisMachine]     VARCHAR(32)    NULL,
    [AnalysisStartDate]   DATETIME       NULL,
    [AnalysisEndDate]     DATETIME       NULL,
    CONSTRAINT [PK_LGames] PRIMARY KEY CLUSTERED ([GameID] ASC),
    CONSTRAINT [FK_LGames_BlackPlayerID] FOREIGN KEY ([BlackPlayerID]) REFERENCES [dim].[Players] ([PlayerID]),
    CONSTRAINT [FK_LGames_ECOID] FOREIGN KEY ([ECOID]) REFERENCES [dim].[ECO] ([ECOID]),
    CONSTRAINT [FK_LGames_EventID] FOREIGN KEY ([EventID]) REFERENCES [dim].[Events] ([EventID]),
    CONSTRAINT [FK_LGames_FileID] FOREIGN KEY ([FileID]) REFERENCES [dbo].[FileHistory] ([FileID]),
    CONSTRAINT [FK_LGames_SiteID] FOREIGN KEY ([SiteID]) REFERENCES [dim].[Sites] ([SiteID]),
    CONSTRAINT [FK_LGames_SourceID] FOREIGN KEY ([SourceID]) REFERENCES [dim].[Sources] ([SourceID]),
    CONSTRAINT [FK_LGames_TimeControlDetailID] FOREIGN KEY ([TimeControlDetailID]) REFERENCES [dim].[TimeControlDetail] ([TimeControlDetailID]),
    CONSTRAINT [FK_LGames_WhitePlayerID] FOREIGN KEY ([WhitePlayerID]) REFERENCES [dim].[Players] ([PlayerID]),
    CONSTRAINT [FK_LGames_AnalysisStatusID] FOREIGN KEY ([AnalysisStatusID]) REFERENCES [dim].[AnalysisStatus] ([AnalysisStatusID]),
    CONSTRAINT [UC_LGames_SiteGameID] UNIQUE NONCLUSTERED ([SourceID] ASC, [SiteID] ASC, [SiteGameID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_LGames_BlackPlayerID]
    ON [lake].[Games]([BlackPlayerID] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_LGames_WhitePlayerID]
    ON [lake].[Games]([WhitePlayerID] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_LGames_EventID]
    ON [lake].[Games]([EventID] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_LGames_SourceID]
    ON [lake].[Games]([SourceID] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_LGames_TimeControlDetailID]
    ON [lake].[Games]([TimeControlDetailID] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_LGames_AnalysisStatusID]
    ON [lake].[Games]([AnalysisStatusID] ASC);
