CREATE PROCEDURE [dbo].[UpdateMoveScores_ScoreID_1] (@FileID int = NULL)

AS

UPDATE ms
SET ms.ScoreValue = CAST(t1.PDF * CAST(POWER(t1.CDF - ISNULL(mp.CDF, 0) - 1, 4) AS decimal(10,9)) AS decimal(10,9)),
	ms.MaxScoreValue = t1.PDF

FROM stat.MoveScores ms
JOIN lake.Moves m ON
	ms.GameID = m.GameID AND
	ms.MoveNumber = m.MoveNumber AND
	ms.ColorID = m.ColorID
JOIN lake.Games g ON m.GameID = g.GameID
JOIN dim.TimeControlDetail td ON g.TimeControlDetailID = td.TimeControlDetailID
LEFT JOIN stat.EvalDistributions t1 ON
	g.SourceID = t1.SourceID AND
	td.TimeControlID = t1.TimeControlID AND
	m.T1_Eval_POV = t1.Evaluation
LEFT JOIN stat.EvalDistributions mp ON
	g.SourceID = mp.SourceID AND
	td.TimeControlID = mp.TimeControlID AND
	m.Move_Eval_POV = mp.Evaluation
LEFT JOIN FileHistory fh ON
	g.FileID = fh.FileID

WHERE m.MoveScored = 1
AND (fh.FileID = @FileID OR ISNULL(@FileID, -1) = -1)
AND ms.ScoreID = 1
