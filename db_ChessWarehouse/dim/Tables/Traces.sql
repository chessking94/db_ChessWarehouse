CREATE TABLE [dim].[Traces] (
	[TraceKey] CHAR(1) COLLATE Latin1_General_CS_AS NOT NULL  --casing matters for this!
	,[TraceDescription] VARCHAR(50) NOT NULL
	,[Scored] BIT CONSTRAINT [DF_Traces_Scored] DEFAULT (0) NULL
	,CONSTRAINT [PK_Traces] PRIMARY KEY CLUSTERED ([TraceKey] ASC)
)
