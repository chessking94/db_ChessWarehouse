CREATE PROCEDURE [dbo].[UpdateMoveScores_ScoreID_1] (@FileID int = NULL)

AS

/*
	*** Score Name = WinProbabilityLost ***
	This score measures the win probability for similiarly evaluated positions (the Max Score) and the accrued points represent the win probability lost by the actual move played.
	The win probability distribution curves as logged in stat.EvalDistributions are fitted from similiar games (source and time control) by the expected score after an evaluation occurs.
	These distribution functions can be thought of as normally distributed "probability density" function f(e), where e is the position evaluation.
	However, the function f(e) is scaled so the global max of f(e) = 1 and the area under the curve does not equal 1, so it is not a true density function.
	The "cumulative density" function F(e) then represents the actual win probability for a given evaluation e.
	The probability lost, found by subtracting the expected win probability of the move played from the expected probability of the best move, is arbitrarily scaled between
		0 and 1 by the function (L - 1)^4, where L is the loss. This scaling is to weight moves with less probability lost as more meaningful.
	The final move score is found by multiplying the scaled probability lost difference by the value of f(e) to ensure 0 <= MoveScore <= f(e).
*/

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
