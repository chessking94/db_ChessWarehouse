CREATE TABLE [fact].[EventScores] (
    [EventID]       INT            NOT NULL,
    [SourceID]      TINYINT        NOT NULL,
    [TimeControlID] TINYINT        NOT NULL,
    [PlayerID]      INT            NOT NULL,
    [ScoreID]       TINYINT        NOT NULL,
    [Score]         DECIMAL (7, 4) NULL,
    [Score_Z]       DECIMAL (9, 6) NULL,
    CONSTRAINT [PK_EventScores] PRIMARY KEY CLUSTERED ([EventID] ASC, [SourceID] ASC, [TimeControlID] ASC, [PlayerID] ASC, [ScoreID] ASC),
    CONSTRAINT [FK_EventScores_FactEvent] FOREIGN KEY ([EventID], [SourceID], [TimeControlID], [PlayerID]) REFERENCES [fact].[Event] ([EventID], [SourceID], [TimeControlID], [PlayerID]) ON DELETE CASCADE,
    CONSTRAINT [FK_EventScores_ScoreID] FOREIGN KEY ([ScoreID]) REFERENCES [dim].[Scores] ([ScoreID])
);

