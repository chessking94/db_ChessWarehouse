﻿CREATE TABLE [rpt].[TimeControlSummary]
(
	SourceName VARCHAR(15) NOT NULL
	,MyColor VARCHAR(5) NOT NULL
	,TimeControlID TINYINT NOT NULL
	,TimeControlName VARCHAR(15) NOT NULL
	,Wins INT
	,Losses INT
	,Draws INT
	,TotalGames INT
	,Score DECIMAL(9,8)
	,AvgRating INT
	,PerfRating INT
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
