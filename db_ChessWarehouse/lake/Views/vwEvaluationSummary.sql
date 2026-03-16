CREATE VIEW [lake].[vwEvaluationSummary]

AS

SELECT
	s.SourceID
	,m.ColorID
	,tc.TimeControlID
	,r.RatingID
	,eg.EvaluationGroupID
	,CASE WHEN m.Move_Rank <= 1 THEN 1 ELSE 0 END AS T1
	,CASE WHEN m.Move_Rank <= 2 THEN 1 ELSE 0 END AS T2
	,CASE WHEN m.Move_Rank <= 3 THEN 1 ELSE 0 END AS T3
	,CASE WHEN m.Move_Rank <= 4 THEN 1 ELSE 0 END AS T4
	,CASE WHEN m.Move_Rank <= 5 THEN 1 ELSE 0 END AS T5
	,m.CP_Loss AS ACPL
	,m.ScACPL
	,m.MoveScored
	,CASE WHEN c.Color = 'White' THEN g.WhiteBerserk ELSE g.BlackBerserk END AS Berserk
	,ms.ScoreValue
	,ms.MaxScoreValue

FROM lake.Moves AS m
INNER JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
	AND m.MoveNumber = ms.MoveNumber
	AND m.ColorID = ms.ColorID
INNER JOIN lake.Games AS g ON m.GameID = g.GameID
INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
INNER JOIN dim.TimeControlDetail AS td ON g.TimeControlDetailID = td.TimeControlDetailID
INNER JOIN dim.TimeControls AS tc ON td.TimeControlID = tc.TimeControlID
INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID
INNER JOIN dim.Ratings AS r ON (CASE WHEN c.Color = 'White' THEN g.WhiteElo ELSE g.BlackElo END) >= r.RatingID
	AND (CASE WHEN c.Color = 'White' THEN g.WhiteElo ELSE g.BlackElo END) <= r.RatingUpperBound
INNER JOIN dim.EvaluationGroups AS eg ON m.T1_Eval_POV >= eg.LBound
	AND m.T1_Eval_POV <= eg.UBound

WHERE ms.ScoreID = 1  --TODO: Revisit this in the future
