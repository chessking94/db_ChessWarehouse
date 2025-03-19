CREATE PROCEDURE [rpt].[UpdateYearlyRoundStatistics]

AS

BEGIN
	TRUNCATE TABLE rpt.YearlyRoundStatistics

	INSERT INTO rpt.YearlyRoundStatistics (
		SourceName
		,MyColor
		,Year
		,RoundNum
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
		,RoundNum
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

	FROM rpt.vwYearlyRoundStatistics
END
