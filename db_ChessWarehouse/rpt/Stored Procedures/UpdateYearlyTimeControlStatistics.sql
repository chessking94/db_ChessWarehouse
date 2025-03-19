CREATE PROCEDURE [rpt].[UpdateYearlyTimeControlStatistics]

AS

BEGIN
	TRUNCATE TABLE rpt.YearlyTimeControlStatistics

	INSERT INTO rpt.YearlyTimeControlStatistics (
		SourceName
		,MyColor
		,Year
		,TimeControlID
		,TimeControlName
		,Wins
		,Losses
		,Draws
		,TotalGames
		,Score
		,AvgRating
		,PerfRating
		,Me_MovesAnalyzed
		,Opp_MovesAnalyzed
		,Me_ACPL
		,Opp_ACPL
		,Me_SDCPL
		,Opp_SDCPL
		,Me_Score
		,Opp_Score
	)

	SELECT
		SourceName
		,MyColor
		,Year
		,TimeControlID
		,TimeControlName
		,Wins
		,Losses
		,Draws
		,TotalGames
		,Score
		,AvgRating
		,PerfRating
		,Me_MovesAnalyzed
		,Opp_MovesAnalyzed
		,Me_ACPL
		,Opp_ACPL
		,Me_SDCPL
		,Opp_SDCPL
		,Me_Score
		,Opp_Score

	FROM rpt.vwYearlyTimeControlStatistics
END
