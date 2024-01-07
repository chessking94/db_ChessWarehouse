CREATE TABLE [stat].[MoveScores] (
    [ScoreID]       TINYINT         NOT NULL,
    [GameID]        INT             NOT NULL,
    [MoveNumber]    SMALLINT        NOT NULL,
    [ColorID]       TINYINT         NOT NULL,
    [ScoreValue]    DECIMAL (10, 9) NULL,
    [MaxScoreValue] DECIMAL (10, 9) NULL,
    CONSTRAINT [PK_MoveScores] PRIMARY KEY CLUSTERED ([ScoreID] ASC, [GameID] ASC, [MoveNumber] ASC, [ColorID] ASC),
    CONSTRAINT [FK_MoveScores_MoveID] FOREIGN KEY ([GameID], [MoveNumber], [ColorID]) REFERENCES [lake].[Moves] ([GameID], [MoveNumber], [ColorID]) ON DELETE CASCADE,
    CONSTRAINT [FK_MoveScores_ScoreID] FOREIGN KEY ([ScoreID]) REFERENCES [dim].[Scores] ([ScoreID]) ON DELETE CASCADE
);

