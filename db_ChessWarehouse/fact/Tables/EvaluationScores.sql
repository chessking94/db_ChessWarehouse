CREATE TABLE [fact].[EvaluationScores] (
    [SourceID]          TINYINT        NOT NULL,
    [EvaluationGroupID] TINYINT        NOT NULL,
    [TimeControlID]     TINYINT        NOT NULL,
    [RatingID]          SMALLINT       NOT NULL,
    [ScoreID]           TINYINT        NOT NULL,
    [Score]             DECIMAL (7, 4) NULL,
    [Score_Z]           DECIMAL (9, 6) NULL,
    [Composite_Z]       DECIMAL (9, 6) NULL,
    [ROI]               AS             ((5)*[Composite_Z]+(50)),
    CONSTRAINT [PK_EvaluationScores] PRIMARY KEY CLUSTERED ([SourceID] ASC, [EvaluationGroupID] ASC, [TimeControlID] ASC, [RatingID] ASC, [ScoreID] ASC),
    CONSTRAINT [FK_EvaluationScores_FactEvaluation] FOREIGN KEY ([SourceID], [EvaluationGroupID], [TimeControlID], [RatingID]) REFERENCES [fact].[Evaluation] ([SourceID], [EvaluationGroupID], [TimeControlID], [RatingID]) ON DELETE CASCADE,
    CONSTRAINT [FK_EvaluationScores_ScoreID] FOREIGN KEY ([ScoreID]) REFERENCES [dim].[Scores] ([ScoreID])
);

