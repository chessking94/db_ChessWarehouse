CREATE TABLE [stat].[EvalDistributionParameters] (
    [SourceID]              TINYINT          NOT NULL,
    [TimeControlID]         TINYINT          NOT NULL,
    [UpdateDate]            DATETIME         CONSTRAINT [DF_EvalDistributionParameters_UpdateDate] DEFAULT (getdate()) NOT NULL,
    [Mean]                  DECIMAL (18, 15) NOT NULL,
    [StandardDeviation]     DECIMAL (18, 15) NOT NULL,
    [PrevMean]              DECIMAL (18, 15) NULL,
    [PrevStandardDeviation] DECIMAL (18, 15) NULL,
    CONSTRAINT [PK_EvalDistributionParameters] PRIMARY KEY CLUSTERED ([SourceID] ASC, [TimeControlID] ASC),
    CONSTRAINT [FK_EvalDistributionParameters_SourceID] FOREIGN KEY ([SourceID]) REFERENCES [dim].[Sources] ([SourceID]),
    CONSTRAINT [FK_EvalDistributionParameters_TimeControlID] FOREIGN KEY ([TimeControlID]) REFERENCES [dim].[TimeControls] ([TimeControlID])
);

