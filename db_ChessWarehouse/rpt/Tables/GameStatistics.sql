CREATE TABLE [rpt].[GameStatistics]
(
	Row_Count INT NOT NULL
	,GameID INT NOT NULL
	,SourceName VARCHAR(15) NOT NULL
	,GameNumber VARCHAR(15) NOT NULL
	,Statistic VARCHAR(14) NOT NULL
	,White DECIMAL(9,6)
	,Black DECIMAL(9,6)
)
GO
