CREATE VIEW [lake].[vwEvaluationSummary]

AS

SELECT
	s.SourceID
	,m.ColorID
	,tc.TimeControlID
	,CASE WHEN m.ColorID = 1 THEN g.WhiteRatingID ELSE g.BlackRatingID END AS RatingID
	,m.T1_EvaluationGroupID AS EvaluationGroupID
	,CASE WHEN m.Move_Rank <= 1 THEN 1 ELSE 0 END AS T1
	,CASE WHEN m.Move_Rank <= 2 THEN 1 ELSE 0 END AS T2
	,CASE WHEN m.Move_Rank <= 3 THEN 1 ELSE 0 END AS T3
	,CASE WHEN m.Move_Rank <= 4 THEN 1 ELSE 0 END AS T4
	,CASE WHEN m.Move_Rank <= 5 THEN 1 ELSE 0 END AS T5
	,m.CP_Loss AS ACPL
	,m.ScACPL
	,m.MoveScored
	,CASE WHEN m.ColorID = 1 THEN g.WhiteBerserk ELSE g.BlackBerserk END AS Berserk
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

WHERE ms.ScoreID = dbo.GetSettingValue('Default Score')
