CREATE PROCEDURE [dbo].[UpdateMoveScores_ScoreID_3] (@FileID int = NULL)

AS

/*
	*** Score Name = EvaluationGroupComparison ***
	This score compares the difficulty of playing similarly evaluated positions (per T5) by the source/time control/rating.
	The more difficult the position is to play (per the T1-T5 percentages logged in fact.EvaluationSplits), the greater the move score can be.
		A benefit of this method is that positions with multiple similarly evaluated top moves will assumed to be more likely to be played, and thus
		less difficult to find and be allocated less importance.
	After subtracting the probability of playing one of the top 5 moves (depending on if T1-T5 is played) from 1, the result is then scaled by a messy function.
	I honestly have no idea how I came up with this function anymore, except that it somewhat looks like a compacted normal distribution and weights positions
		where the historical win rate closer to 50% as more.
*/

UPDATE ms
SET ms.ScoreValue = (
	(1 - (
	CASE m.Move_Rank 
		WHEN 1 THEN sp.T1
		WHEN 2 THEN sp.T2
		WHEN 3 THEN sp.T3
		WHEN 4 THEN sp.T4
		WHEN 5 THEN sp.T5
		ELSE (CASE WHEN sp.T1 IS NULL THEN NULL ELSE 1 END)
	END))*CAST((6*EXP(-(2*LOG(5+2*SQRT(6)))*(sp.WinPercentage-0.5)))/POWER((1+EXP(-(2*LOG(5+2*SQRT(6)))*(sp.WinPercentage-0.5))), 2)-0.5 AS decimal(10,9))
),
	ms.MaxScoreValue = (1 - sp.T1)*CAST((6*EXP(-(2*LOG(5+2*SQRT(6)))*(sp.WinPercentage-0.5)))/POWER((1+EXP(-(2*LOG(5+2*SQRT(6)))*(sp.WinPercentage-0.5))), 2)-0.5 AS decimal(10,9))

FROM stat.MoveScores ms
JOIN lake.Moves m ON
	ms.GameID = m.GameID AND
	ms.MoveNumber = m.MoveNumber AND
	ms.ColorID = m.ColorID
JOIN lake.Games g ON m.GameID = g.GameID
JOIN dim.TimeControlDetail td ON g.TimeControlDetailID = td.TimeControlDetailID
JOIN dim.Colors c ON m.ColorID = c.ColorID
JOIN dim.Ratings r ON
	(CASE WHEN c.Color = 'White' THEN g.WhiteElo ELSE g.BlackElo END) >= r.RatingID AND
	(CASE WHEN c.Color = 'White' THEN g.WhiteElo ELSE g.BlackElo END) <= r.RatingUpperBound
LEFT JOIN FileHistory fh ON
	g.FileID = fh.FileID
JOIN dim.EvaluationGroups eg1 ON
	m.T1_Eval_POV >= eg1.LBound AND
	m.T1_Eval_POV <= eg1.UBound
LEFT JOIN dim.EvaluationGroups eg2 ON
	m.T2_Eval_POV >= eg2.LBound AND
	m.T2_Eval_POV <= eg2.UBound
LEFT JOIN dim.EvaluationGroups eg3 ON
	m.T3_Eval_POV >= eg3.LBound AND
	m.T3_Eval_POV <= eg3.UBound
LEFT JOIN dim.EvaluationGroups eg4 ON
	m.T4_Eval_POV >= eg4.LBound AND
	m.T4_Eval_POV <= eg4.UBound
LEFT JOIN dim.EvaluationGroups eg5 ON
	m.T5_Eval_POV >= eg5.LBound AND
	m.T5_Eval_POV <= eg5.UBound
LEFT JOIN fact.EvaluationSplits sp ON
	(CASE g.SourceID WHEN 1 THEN 3 WHEN 2 THEN 4 ELSE g.SourceID END) = sp.SourceID AND
	(CASE WHEN g.SourceID = 1 THEN 5 ELSE td.TimeControlID END) = sp.TimeControlID AND
	(CASE WHEN g.SourceID = 2 AND r.RatingID < 2200 THEN 2200 ELSE r.RatingID END) = sp.RatingID AND
	eg1.EvaluationGroupID = sp.EvaluationGroupID_T1 AND
	ISNULL(eg2.EvaluationGroupID, 0) = sp.EvaluationGroupID_T2 AND
	ISNULL(eg3.EvaluationGroupID, 0) = sp.EvaluationGroupID_T3 AND
	ISNULL(eg4.EvaluationGroupID, 0) = sp.EvaluationGroupID_T4 AND
	ISNULL(eg5.EvaluationGroupID, 0) = sp.EvaluationGroupID_T5

WHERE m.MoveScored = 1
AND (fh.FileID = @FileID OR ISNULL(@FileID, -1) = -1)
AND ms.ScoreID = 3

