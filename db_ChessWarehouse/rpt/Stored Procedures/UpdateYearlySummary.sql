CREATE PROCEDURE [rpt].[UpdateYearlySummary]

AS

BEGIN
	TRUNCATE TABLE rpt.YearlySummary

	INSERT INTO rpt.YearlySummary (
		SourceName
		,MyColor
		,Year
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

	FROM rpt.vwYearlySummary
END
