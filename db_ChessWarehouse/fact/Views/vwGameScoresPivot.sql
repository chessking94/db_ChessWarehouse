CREATE VIEW [fact].[vwGameScoresPivot]

AS

SELECT
pt.*

FROM (
	SELECT
		gs.SourceID
		,gs.GameID
		,gs.ColorID
		,sc.ScoreName
		,gs.Score

	FROM fact.GameScores AS gs
	INNER JOIN dim.Scores AS sc ON gs.ScoreID = sc.ScoreID
) s
PIVOT (
	SUM(s.Score) FOR s.ScoreName IN ([EvaluationGroupComparison], [TestScore], [WinProbabilityLost], [WinProbabilityLostEqual])
) AS pt
