CREATE PROCEDURE [rpt].[UpdateYearlyTStatistics]

AS

BEGIN
	TRUNCATE TABLE rpt.YearlyTStatistics

	INSERT INTO rpt.YearlyTStatistics (
		SourceName
		,MyColor
		,Year
		,Games
		,Me_MovesAnalyzed
		,Me_T1
		,Me_T2
		,Me_T3
		,Me_T4
		,Me_T5
		,Opp_MovesAnalyzed
		,Opp_T1
		,Opp_T2
		,Opp_T3
		,Opp_T4
		,Opp_T5
	)

	SELECT
		SourceName
		,MyColor
		,Year
		,Games
		,Me_MovesAnalyzed
		,Me_T1
		,Me_T2
		,Me_T3
		,Me_T4
		,Me_T5
		,Opp_MovesAnalyzed
		,Opp_T1
		,Opp_T2
		,Opp_T3
		,Opp_T4
		,Opp_T5

	FROM rpt.vwYearlyTStatistics
END
