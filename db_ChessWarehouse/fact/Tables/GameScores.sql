CREATE TABLE [fact].[GameScores] (
    [SourceID] TINYINT        NOT NULL,
    [GameID]   INT            NOT NULL,
    [ColorID]  TINYINT        NOT NULL,
    [ScoreID]  TINYINT        NOT NULL,
    [Score]    DECIMAL (7, 4) NULL,
    [Score_Z]  DECIMAL (9, 6) NULL,
    [Composite_Z]     DECIMAL (9, 6) NULL,
    [ROI]             AS             ((5)*[Composite_Z]+(50)),
    CONSTRAINT [PK_GameScores] PRIMARY KEY CLUSTERED ([SourceID] ASC, [GameID] ASC, [ColorID] ASC, [ScoreID] ASC),
    CONSTRAINT [FK_GameScores_FactGame] FOREIGN KEY ([SourceID], [GameID], [ColorID]) REFERENCES [fact].[Game] ([SourceID], [GameID], [ColorID]) ON DELETE CASCADE,
    CONSTRAINT [FK_GameScores_ScoreID] FOREIGN KEY ([ScoreID]) REFERENCES [dim].[Scores] ([ScoreID])
);

