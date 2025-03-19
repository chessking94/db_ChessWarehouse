CREATE TABLE [rpt].[OpponentSummary]
(
	SourceName VARCHAR(15) NOT NULL
	,Opp_Color VARCHAR(5) NOT NULL
	,Opp_LastName VARCHAR(50) NOT NULL
	,Opp_FirstName VARCHAR(30)
	,Wins INT
	,Losses INT
	,Draws INT
	,TotalGames INT
	,Score DECIMAL(9,8)
	,Me_MovesAnalyzed INT
	,Opp_MovesAnalyzed INT
	,Me_ACPL DECIMAL(9,6)
	,Opp_ACPL DECIMAL(9,6)
	,Me_SDCPL DECIMAL(9,6)
	,Opp_SDCPL DECIMAL(9,6)
	,Me_Score DECIMAL(7,4)
	,Opp_Score DECIMAL(7,4)
)
GO
