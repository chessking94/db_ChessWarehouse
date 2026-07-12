CREATE TABLE [stat].[EvalDistributionParameters] (
	[SourceID] TINYINT NOT NULL
	,[TimeControlID] TINYINT NOT NULL
	,[UpdateDate] DATETIME CONSTRAINT [DF_EvalDistributionParameters_UpdateDate] DEFAULT (GETDATE()) NOT NULL
	,[p_0] DECIMAL(18,15) NOT NULL
	,[p_1] DECIMAL(18,15) NOT NULL
	,[Prev_p_0] DECIMAL(18,15) NULL
	,[Prev_p_1] DECIMAL(18,15) NULL
	,CONSTRAINT [PK_EvalDistributionParameters] PRIMARY KEY CLUSTERED ([SourceID] ASC, [TimeControlID] ASC)
	,CONSTRAINT [FK_EvalDistributionParameters_SourceID] FOREIGN KEY ([SourceID]) REFERENCES [dim].[Sources] ([SourceID])
	,CONSTRAINT [FK_EvalDistributionParameters_TimeControlID] FOREIGN KEY ([TimeControlID]) REFERENCES [dim].[TimeControls] ([TimeControlID])
)
