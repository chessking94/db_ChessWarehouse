CREATE TABLE [dim].[EvaluationGroups] (
	[EvaluationGroupID] TINYINT NOT NULL
	,[LBound] DECIMAL(5,2) NULL
	,[UBound] DECIMAL(5,2) NULL
	,[Meaning] VARCHAR (8) NULL
	,[Range] AS ((CONVERT(VARCHAR(7), [LBound]) + '_') + CONVERT(VARCHAR(7), [UBound]))
	,CONSTRAINT [PK_EvaluationGroups] PRIMARY KEY CLUSTERED ([EvaluationGroupID] ASC)
)
