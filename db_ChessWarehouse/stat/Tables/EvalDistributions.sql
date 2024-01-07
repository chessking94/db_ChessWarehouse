CREATE TABLE [stat].[EvalDistributions] (
    [SourceID]       TINYINT         NOT NULL,
    [TimeControlID]  TINYINT         NOT NULL,
    [Evaluation]     DECIMAL (5, 2)  NOT NULL,
    [DistributionID] TINYINT         NOT NULL,
    [PDF]            DECIMAL (10, 9) NULL,
    [CDF]            DECIMAL (10, 9) NULL,
    CONSTRAINT [PK_EvalDistributions] PRIMARY KEY CLUSTERED ([SourceID] ASC, [TimeControlID] ASC, [Evaluation] ASC, [DistributionID] ASC),
    CONSTRAINT [FK_EvalDistribution_DistributionID] FOREIGN KEY ([DistributionID]) REFERENCES [stat].[DistributionTypes] ([DistributionID]),
    CONSTRAINT [FK_EvalDistribution_SourceID] FOREIGN KEY ([SourceID]) REFERENCES [dim].[Sources] ([SourceID]),
    CONSTRAINT [FK_EvalDistribution_TimeControlID] FOREIGN KEY ([TimeControlID]) REFERENCES [dim].[TimeControls] ([TimeControlID])
);

