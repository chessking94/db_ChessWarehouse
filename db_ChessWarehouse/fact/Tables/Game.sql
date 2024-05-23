﻿CREATE TABLE [fact].[Game] (
    [SourceID]        TINYINT        NOT NULL,
    [GameID]          INT            NOT NULL,
    [ColorID]         TINYINT        NOT NULL,
    [TimeControlID]   TINYINT        NOT NULL,
    [PlayerID]        INT            NOT NULL,
    [RatingID]        SMALLINT       NOT NULL,
    [CalculationDate] DATETIME       CONSTRAINT [DF_FGame_CalculationDate] DEFAULT (getdate()) NOT NULL,
    [CPL_Moves]       SMALLINT       NOT NULL,
    [CPL_1]           SMALLINT       NOT NULL,
    [CPL_2]           SMALLINT       NOT NULL,
    [CPL_3]           SMALLINT       NOT NULL,
    [CPL_4]           SMALLINT       NOT NULL,
    [CPL_5]           SMALLINT       NOT NULL,
    [CPL_6]           SMALLINT       NOT NULL,
    [CPL_7]           SMALLINT       NOT NULL,
    [CPL_8]           SMALLINT       NOT NULL,
    [MovesAnalyzed]   SMALLINT       NOT NULL,
    [ACPL]            DECIMAL (9, 6) NULL,
    [SDCPL]           DECIMAL (9, 6) NULL,
    [ScACPL]          DECIMAL (9, 6) NULL,
    [ScSDCPL]         DECIMAL (9, 6) NULL,
    [T1]              DECIMAL (7, 6) NULL,
    [T2]              DECIMAL (7, 6) NULL,
    [T3]              DECIMAL (7, 6) NULL,
    [T4]              DECIMAL (7, 6) NULL,
    [T5]              DECIMAL (7, 6) NULL,
    [ACPL_Z]          DECIMAL (9, 6) NULL,
    [SDCPL_Z]         DECIMAL (9, 6) NULL,
    [ScACPL_Z]        DECIMAL (9, 6) NULL,
    [ScSDCPL_Z]       DECIMAL (9, 6) NULL,
    [T1_Z]            DECIMAL (9, 6) NULL,
    [T2_Z]            DECIMAL (9, 6) NULL,
    [T3_Z]            DECIMAL (9, 6) NULL,
    [T4_Z]            DECIMAL (9, 6) NULL,
    [T5_Z]            DECIMAL (9, 6) NULL,
    CONSTRAINT [PK_FGame] PRIMARY KEY CLUSTERED ([SourceID] ASC, [GameID] ASC, [ColorID] ASC),
    CONSTRAINT [FK_FGame_ColorID] FOREIGN KEY ([ColorID]) REFERENCES [dim].[Colors] ([ColorID]),
    CONSTRAINT [FK_FGame_GameID] FOREIGN KEY ([GameID]) REFERENCES [lake].[Games] ([GameID]),
    CONSTRAINT [FK_FGame_PlayerID] FOREIGN KEY ([PlayerID]) REFERENCES [dim].[Players] ([PlayerID]),
    CONSTRAINT [FK_FGame_RatingID] FOREIGN KEY ([RatingID]) REFERENCES [dim].[Ratings] ([RatingID]),
    CONSTRAINT [FK_FGame_SourceID] FOREIGN KEY ([SourceID]) REFERENCES [dim].[Sources] ([SourceID]),
    CONSTRAINT [FK_FGame_TimeControlID] FOREIGN KEY ([TimeControlID]) REFERENCES [dim].[TimeControls] ([TimeControlID])
);

