CREATE VIEW fact.vwEventScoresPivot AS
SELECT
pt.*

FROM (
	SELECT
	es.EventID,
	es.SourceID,
	es.TimeControlID,
	es.PlayerID,
	sc.ScoreName,
	es.Score
	FROM fact.EventScores es
	JOIN dim.Scores sc ON es.ScoreID = sc.ScoreID
) s
PIVOT (
	SUM(s.Score) FOR s.ScoreName IN ([EvaluationGroupComparison], [TestScore], [WinProbabilityLost], [WinProbabilityLostEqual])
) AS pt
