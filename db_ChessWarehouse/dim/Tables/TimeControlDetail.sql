CREATE TABLE [dim].[TimeControlDetail] (
	[TimeControlDetailID] SMALLINT IDENTITY(1,1) NOT NULL
	,[TimeControlDetail] VARCHAR(15) NOT NULL
	,[TimeControlID] TINYINT NOT NULL
	,[Seconds] AS (CASE WHEN CHARINDEX('+', [TimeControlDetail]) > 0 THEN CONVERT(SMALLINT, LEFT([TimeControlDetail], CHARINDEX('+', [TimeControlDetail]) - 1)) END) PERSISTED
	,[Increment] AS (CASE WHEN CHARINDEX('+', [TimeControlDetail]) > 0 THEN CONVERT(SMALLINT, SUBSTRING([TimeControlDetail], CHARINDEX('+', [TimeControlDetail]) + 1, LEN([TimeControlDetail]))) END) PERSISTED
	,CONSTRAINT [PK_TimeControlDetail] PRIMARY KEY CLUSTERED ([TimeControlDetailID] ASC)
	,CONSTRAINT [FK_TimeControlDetail_TimeControlID] FOREIGN KEY ([TimeControlID]) REFERENCES [dim].[TimeControls] ([TimeControlID])
	,CONSTRAINT [UC_TimeControlDetail_TimeControlDetail] UNIQUE NONCLUSTERED ([TimeControlDetail] ASC)
)
