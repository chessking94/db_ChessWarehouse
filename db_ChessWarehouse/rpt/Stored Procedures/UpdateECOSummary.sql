CREATE PROCEDURE [rpt].[UpdateECOSummary]

AS

BEGIN
	DELETE FROM rpt.ECOSummary

	INSERT INTO rpt.ECOSummary (
		ECO_Group
		,SourceName
		,MyColor
		,Opening_Name
		,ECO_Code
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
		ECO_Group
		,SourceName
		,MyColor
		,Opening_Name
		,ECO_Code
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

	FROM rpt.vwECOSummary
END
