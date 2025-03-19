CREATE PROCEDURE [rpt].[UpdateOpponentSummary]

AS

BEGIN
	TRUNCATE TABLE rpt.OpponentSummary

	INSERT INTO rpt.OpponentSummary (
		SourceName
		,Opp_Color
		,Opp_LastName
		,Opp_FirstName
		,Wins
		,Losses
		,Draws
		,TotalGames
		,Score
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
		,Opp_Color
		,Opp_LastName
		,Opp_FirstName
		,Wins
		,Losses
		,Draws
		,TotalGames
		,Score
		,Me_MovesAnalyzed
		,Opp_MovesAnalyzed
		,Me_ACPL
		,Opp_ACPL
		,Me_SDCPL
		,Opp_SDCPL
		,Me_Score
		,Opp_Score

	FROM rpt.vwOpponentSummary
END
