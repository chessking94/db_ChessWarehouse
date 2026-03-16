CREATE PROCEDURE [dbo].[UpdateMoveScores_ScoreID_2] (
	@FileID INT = NULL
)

AS

/*
	*** Score Name = WinProbabilityLostEqual ***
	This score is identical to WinProbabilityLost except it always uses the same source and time control for comparison purposes.
	The source and time control are set in dbo.Settings by the values associated with Name = WinProbabilityLostEqual Source and Name = WinProbabilityLostEqual Time Control.
*/

BEGIN
	UPDATE ms

	SET ms.ScoreValue = CAST(t1.PDF * CAST(POWER(t1.CDF - ISNULL(mp.CDF, 0) - 1, 4) AS DECIMAL(10,9)) AS DECIMAL(10,9))
		,ms.MaxScoreValue = t1.PDF

	FROM stat.MoveScores AS ms
	INNER JOIN lake.Moves AS m ON ms.GameID = m.GameID
		AND ms.MoveNumber = m.MoveNumber
		AND ms.ColorID = m.ColorID
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	INNER JOIN dim.TimeControlDetail AS td ON g.TimeControlDetailID = td.TimeControlDetailID
	LEFT JOIN stat.EvalDistributions AS t1 ON m.T1_Eval_POV = t1.Evaluation
	LEFT JOIN stat.EvalDistributions AS mp ON t1.SourceID = mp.SourceID
		AND t1.TimeControlID = mp.TimeControlID
		AND m.Move_Eval_POV = mp.Evaluation
	LEFT JOIN FileHistory AS fh ON g.FileID = fh.FileID

	WHERE m.MoveScored = 1
	AND t1.SourceID = dbo.GetSettingValue('WinProbabilityLostEqual Source')
	AND t1.TimeControlID = dbo.GetSettingValue('WinProbabilityLostEqual Time Control')
	AND (fh.FileID = @FileID OR ISNULL(@FileID, -1) = -1)
	AND ms.ScoreID = 2
END
