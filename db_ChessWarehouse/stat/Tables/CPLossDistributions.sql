CREATE TABLE [stat].[CPLossDistributions] (
    [SourceID]          TINYINT         NOT NULL,
    [TimeControlID]     TINYINT         NOT NULL,
    [RatingID]          SMALLINT        NOT NULL,
    [EvaluationGroupID] TINYINT         NOT NULL,
    [CP_Loss]           DECIMAL (5, 2)  NOT NULL,
    [DistributionID]    TINYINT         NOT NULL,
    [PDF]               DECIMAL (10, 9) NULL,
    [CDF]               DECIMAL (10, 9) NULL,
    CONSTRAINT [PK_CPLossDistributions] PRIMARY KEY CLUSTERED ([SourceID] ASC, [TimeControlID] ASC, [RatingID] ASC, [EvaluationGroupID] ASC, [CP_Loss] ASC, [DistributionID] ASC),
    CONSTRAINT [FK_CPLossDistributions_DistributionID] FOREIGN KEY ([DistributionID]) REFERENCES [stat].[DistributionTypes] ([DistributionID]),
    CONSTRAINT [FK_CPLossDistributions_EvaluationGroupID] FOREIGN KEY ([EvaluationGroupID]) REFERENCES [dim].[EvaluationGroups] ([EvaluationGroupID]),
    CONSTRAINT [FK_CPLossDistributions_RatingID] FOREIGN KEY ([RatingID]) REFERENCES [dim].[Ratings] ([RatingID]),
    CONSTRAINT [FK_CPLossDistributions_SourceID] FOREIGN KEY ([SourceID]) REFERENCES [dim].[Sources] ([SourceID]),
    CONSTRAINT [FK_CPLossDistributions_TimeControlID] FOREIGN KEY ([TimeControlID]) REFERENCES [dim].[TimeControls] ([TimeControlID])
);

