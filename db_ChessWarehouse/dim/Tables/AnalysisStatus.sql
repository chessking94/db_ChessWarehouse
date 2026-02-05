CREATE TABLE [dim].[AnalysisStatus]
(
	[AnalysisStatusID] TINYINT IDENTITY(1,1) NOT NULL
	,[AnalysisStatusName] VARCHAR(15) NOT NULL
	,CONSTRAINT [PK_AnalysisStatus] PRIMARY KEY CLUSTERED ([AnalysisStatusID] ASC)
)
