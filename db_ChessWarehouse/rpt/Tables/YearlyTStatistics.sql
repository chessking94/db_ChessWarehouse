CREATE TABLE [rpt].[YearlyTStatistics]
(
	SourceName VARCHAR(15) NOT NULL
	,MyColor VARCHAR(5) NOT NULL
	,Year INT NOT NULL
	,Games INT
	,Me_MovesAnalyzed INT
	,Me_T1 DECIMAL(9,8)
	,Me_T2 DECIMAL(9,8)
	,Me_T3 DECIMAL(9,8)
	,Me_T4 DECIMAL(9,8)
	,Me_T5 DECIMAL(9,8)
	,Opp_MovesAnalyzed INT
	,Opp_T1 DECIMAL(9,8)
	,Opp_T2 DECIMAL(9,8)
	,Opp_T3 DECIMAL(9,8)
	,Opp_T4 DECIMAL(9,8)
	,Opp_T5 DECIMAL(9,8)
)
GO
