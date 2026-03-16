CREATE TABLE [rpt].[TimeControlSummary]
(
	SourceName VARCHAR(15) NOT NULL
	,MyColor VARCHAR(5) NOT NULL
	,TimeControlID TINYINT NOT NULL
	,TimeControlName VARCHAR(15) NOT NULL
	,Wins INT NULL
	,Losses INT NULL
	,Draws INT NULL
	,TotalGames INT NULL
	,Score DECIMAL(9,8) NULL
	,AvgRating INT NULL
	,PerfRating INT NULL
	,Me_MovesAnalyzed INT NULL
	,Opp_MovesAnalyzed INT NULL
	,Me_ACPL DECIMAL(9,6) NULL
	,Opp_ACPL DECIMAL(9,6) NULL
	,Me_SDCPL DECIMAL(9,6) NULL
	,Opp_SDCPL DECIMAL(9,6) NULL
	,Me_Score DECIMAL(7,4) NULL
	,Opp_Score DECIMAL(7,4) NULL
)
