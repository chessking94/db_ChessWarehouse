CREATE PROCEDURE [dbo].[UpdateMoveScores_ScoreID_4] (
	@FileID INT = NULL
)

AS

/*
	*** Score Name = ContextualMoveQuality ***
	The score is a combination of the previous score models WinProbabilityLost and EvaluationGroupComparison. Rather than focusing solely on the change in win probability or how similarly
		rated players in the same source/time control have performed historically, this model attempts to combine the best attributes of each.
	I found WinProbabilityLost to be a decent score, but it had no insight into possible position complexity. EvaluationGroupComparison on the other had did sort of did, but had abstracted
		away the per-move meaningfulness.
	The win probability distribution curves as logged in stat.EvalDistributions are fitted from similiar games (source and time control) by the expected score after an evaluation occurs.
	These distribution functions can be thought of as normally distributed "probability density" function f(e), where e is the position evaluation.
	However, the function f(e) is scaled so the global max of f(e) = 1 and the area under the curve does not equal 1, so it is not a true density function.
	The "cumulative density" function F(e) then represents the actual win probability for a given evaluation e.
	The complexity factor is performed outside of the database and loaded separately, but it is determined on a per-move basis and dependent on currently 12 factors:
		source, time control, T1-T5_Eval_POV (lake.Moves), and the historical liklihood of the T1-T5 being played (fact.EvaluationSplits).
	The probability lost, found by subtracting the expected win probability of the move played from the expected probability of the best move, is arbitrarily scaled between
		0 and 1 by the function 1/EXP(5L), where L is the loss. This scaling is to weight moves with less probability lost as more meaningful.
	The final move score is found by multiplying together the scaled probability lost difference, the complexity, and the value of f(e) with a result between 0 and 1.
*/

BEGIN
	UPDATE ms

	SET ms.ScoreValue = CAST(t1.PDF * m.Complexity * 1.0/EXP(5 * (t1.CDF - ISNULL(mp.CDF, 0))) AS DECIMAL(10,9))
		,ms.MaxScoreValue = CAST(t1.PDF * m.Complexity AS DECIMAL(10,9))

	FROM stat.MoveScores AS ms
	INNER JOIN lake.Moves AS m ON ms.GameID = m.GameID
		AND ms.MoveNumber = m.MoveNumber
		AND ms.ColorID = m.ColorID
		AND m.MoveScored = 1
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
		AND (g.FileID = @FileID OR @FileID IS NULL)  --ability to calculate a subset of games or the entire database
	INNER JOIN dim.TimeControlDetail AS td ON g.TimeControlDetailID = td.TimeControlDetailID
	LEFT JOIN stat.EvalDistributions AS t1 ON g.SourceID = t1.SourceID  --if there is no record in t1, a null score is expected
		AND td.TimeControlID = t1.TimeControlID
		AND m.T1_Eval_POV = t1.Evaluation
		AND t1.DistributionID = 3
	LEFT JOIN stat.EvalDistributions AS mp ON g.SourceID = mp.SourceID  --null handling is required for mp above, in case of a terrible blunder
		AND td.TimeControlID = mp.TimeControlID
		AND m.Move_Eval_POV = mp.Evaluation
		AND mp.DistributionID = 3

	WHERE ms.ScoreID = 4

	OPTION (RECOMPILE)
END