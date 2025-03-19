CREATE PROCEDURE [rpt].[UpdateTimeControlSummary]

AS

BEGIN
	TRUNCATE TABLE rpt.TimeControlSummary

	INSERT INTO rpt.TimeControlSummary (
		SourceName
		,MyColor
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

	FROM rpt.vwTimeControlSummary
END
