CREATE VIEW fact.vwEvaluationScoresPivot AS
SELECT
pt.*

FROM (
	SELECT
	es.SourceID,
	es.EvaluationGroupID,
	es.RatingID,
	es.TimeControlID,
	sc.ScoreName,
	es.Score
	FROM fact.EvaluationScores es
	JOIN dim.Scores sc ON es.ScoreID = sc.ScoreID
) s
PIVOT (
	SUM(s.Score) FOR s.ScoreName IN ([EvaluationGroupComparison], [TestScore], [WinProbabilityLost], [WinProbabilityLostEqual])
) AS pt
