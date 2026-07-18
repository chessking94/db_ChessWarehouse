CREATE TABLE [fact].[EvaluationSplitsRating] (
	[SourceID] TINYINT NOT NULL
	,[TimeControlID] TINYINT NOT NULL
	,[RatingID] SMALLINT NOT NULL
	,[EvaluationGroupID_T1] TINYINT NOT NULL
	,[EvaluationGroupID_T2] TINYINT NOT NULL
	,[EvaluationGroupID_T3] TINYINT NOT NULL
	,[EvaluationGroupID_T4] TINYINT NOT NULL
	,[EvaluationGroupID_T5] TINYINT NOT NULL
	,[CalculationDate] DATETIME CONSTRAINT [DF_EvaluationSplitsRating_CalculationDate] DEFAULT (GETDATE()) NOT NULL
	,[MovesAnalyzed] INT NOT NULL
	,[ACPL] DECIMAL(9,6) NULL
	,[SDCPL] DECIMAL(9,6) NULL
	,[ScACPL] DECIMAL(9,6) NULL
	,[ScSDCPL] DECIMAL(9,6) NULL
	,[T1] DECIMAL(7,6) NULL
	,[T2] DECIMAL(7,6) NULL
	,[T3] DECIMAL(7,6) NULL
	,[T4] DECIMAL(7,6) NULL
	,[T5] DECIMAL(7,6) NULL
	,[WinPercentage] DECIMAL(7,6) NULL
	,[ScalingFactor] AS CAST((6*EXP(-(2*LOG(5+2*SQRT(6)))*(WinPercentage-0.5)))/POWER((1+EXP(-(2*LOG(5+2*SQRT(6)))*(WinPercentage-0.5))), 2)-0.5 AS DECIMAL(10,9)) PERSISTED  --this is basically a bell curve with a max of y = 1 of x-intercepts of 0 and 1
	,CONSTRAINT [PK_EvaluationSplitsRating] PRIMARY KEY CLUSTERED ([SourceID] ASC, [TimeControlID] ASC, [RatingID] ASC, [EvaluationGroupID_T1] ASC, [EvaluationGroupID_T2] ASC, [EvaluationGroupID_T3] ASC, [EvaluationGroupID_T4] ASC, [EvaluationGroupID_T5] ASC)
	,CONSTRAINT [FK_EvaluationSplitsRating_EvaluationGroupIDT1] FOREIGN KEY ([EvaluationGroupID_T1]) REFERENCES [dim].[EvaluationGroups] ([EvaluationGroupID])
	,CONSTRAINT [FK_EvaluationSplitsRating_EvaluationGroupIDT2] FOREIGN KEY ([EvaluationGroupID_T2]) REFERENCES [dim].[EvaluationGroups] ([EvaluationGroupID])
	,CONSTRAINT [FK_EvaluationSplitsRating_EvaluationGroupIDT3] FOREIGN KEY ([EvaluationGroupID_T3]) REFERENCES [dim].[EvaluationGroups] ([EvaluationGroupID])
	,CONSTRAINT [FK_EvaluationSplitsRating_EvaluationGroupIDT4] FOREIGN KEY ([EvaluationGroupID_T4]) REFERENCES [dim].[EvaluationGroups] ([EvaluationGroupID])
	,CONSTRAINT [FK_EvaluationSplitsRating_EvaluationGroupIDT5] FOREIGN KEY ([EvaluationGroupID_T5]) REFERENCES [dim].[EvaluationGroups] ([EvaluationGroupID])
	,CONSTRAINT [FK_EvaluationSplitsRating_RatingID] FOREIGN KEY ([RatingID]) REFERENCES [dim].[Ratings] ([RatingID])
	,CONSTRAINT [FK_EvaluationSplitsRating_SourceID] FOREIGN KEY ([SourceID]) REFERENCES [dim].[Sources] ([SourceID])
	,CONSTRAINT [FK_EvaluationSplitsRating_TimeControlID] FOREIGN KEY ([TimeControlID]) REFERENCES [dim].[TimeControls] ([TimeControlID])
)

GO
CREATE NONCLUSTERED INDEX [IDX_EvaluationSplitsRating_ScalingFactor] ON [fact].[EvaluationSplitsRating] ([ScalingFactor]) INCLUDE (T1, T2, T3, T4, T5, ScACPL, ScSDCPL)
