CREATE TABLE [stat].[CPLossDistributionParameters] (
    [SourceID]          TINYINT          NOT NULL,
    [TimeControlID]     TINYINT          NOT NULL,
    [RatingID]          SMALLINT         NOT NULL,
    [EvaluationGroupID] TINYINT          NOT NULL,
    [UpdateDate]        DATETIME         CONSTRAINT [DF_CPLossDistributionParameters_UpdateDate] DEFAULT (getdate()) NOT NULL,
    [Alpha]             DECIMAL (19, 15) NOT NULL,
    [Beta]              DECIMAL (19, 15) NOT NULL,
    [PrevAlpha]         DECIMAL (19, 15) NULL,
    [PrevBeta]          DECIMAL (19, 15) NULL,
    CONSTRAINT [PK_CPLossDistributionParameters] PRIMARY KEY CLUSTERED ([SourceID] ASC, [TimeControlID] ASC, [RatingID] ASC, [EvaluationGroupID] ASC),
    CONSTRAINT [FK_CPLossDistributionParameters_EvaluationGroupID] FOREIGN KEY ([EvaluationGroupID]) REFERENCES [dim].[EvaluationGroups] ([EvaluationGroupID]),
    CONSTRAINT [FK_CPLossDistributionParameters_RatingID] FOREIGN KEY ([RatingID]) REFERENCES [dim].[Ratings] ([RatingID]),
    CONSTRAINT [FK_CPLossDistributionParameters_SourceID] FOREIGN KEY ([SourceID]) REFERENCES [dim].[Sources] ([SourceID]),
    CONSTRAINT [FK_CPLossDistributionParameters_TimeControlID] FOREIGN KEY ([TimeControlID]) REFERENCES [dim].[TimeControls] ([TimeControlID])
);

