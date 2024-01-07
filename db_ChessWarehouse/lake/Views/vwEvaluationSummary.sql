





CREATE VIEW [lake].[vwEvaluationSummary]

AS

SELECT
s.SourceID,
m.ColorID,
tc.TimeControlID,
r.RatingID,
eg.EvaluationGroupID,
CASE WHEN m.Move_Rank <= 1 THEN 1 ELSE 0 END AS T1,
CASE WHEN m.Move_Rank <= 2 THEN 1 ELSE 0 END AS T2,
CASE WHEN m.Move_Rank <= 3 THEN 1 ELSE 0 END AS T3,
CASE WHEN m.Move_Rank <= 4 THEN 1 ELSE 0 END AS T4,
CASE WHEN m.Move_Rank <= 5 THEN 1 ELSE 0 END AS T5,
m.CP_Loss AS ACPL,
m.ScACPL,
m.MoveScored,
CASE WHEN c.Color = 'White' THEN g.WhiteBerserk ELSE g.BlackBerserk END AS Berserk,
ms.ScoreValue,
ms.MaxScoreValue

FROM lake.Moves m
JOIN stat.MoveScores ms ON
	m.GameID = ms.GameID AND
	m.MoveNumber = ms.MoveNumber AND
	m.ColorID = ms.ColorID
JOIN lake.Games g ON
	m.GameID = g.GameID
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.TimeControlDetail td ON
	g.TimeControlDetailID = td.TimeControlDetailID
JOIN dim.TimeControls tc ON
	td.TimeControlID = tc.TimeControlID
JOIN dim.Colors c ON m.ColorID = c.ColorID
JOIN dim.Ratings r ON
	(CASE WHEN c.Color = 'White' THEN g.WhiteElo ELSE g.BlackElo END) >= r.RatingID AND
	(CASE WHEN c.Color = 'White' THEN g.WhiteElo ELSE g.BlackElo END) <= r.RatingUpperBound
JOIN dim.EvaluationGroups eg ON
	m.T1_Eval_POV >= eg.LBound AND
	m.T1_Eval_POV <= eg.UBound

WHERE ms.ScoreID = 1 --TODO: Revisit this in the future

