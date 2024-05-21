CREATE PROCEDURE [dbo].[UpdateMoveScores_ScoreID_0] (@FileID int = NULL)

AS

/*
	*** Score Name = TestScore ***
	This proc is intended to be used for score testing.
	It's main state is to set ms.ScoreValue and ms.MaxScoreValue to NULL.
*/

UPDATE ms
SET ms.ScoreValue = NULL,
	ms.MaxScoreValue = NULL

FROM stat.MoveScores ms
JOIN lake.Moves m ON
	ms.GameID = m.GameID AND
	ms.MoveNumber = m.MoveNumber AND
	ms.ColorID = m.ColorID
JOIN lake.Games g ON m.GameID = g.GameID
LEFT JOIN FileHistory fh ON
	g.FileID = fh.FileID

WHERE m.MoveScored = 1
AND (fh.FileID = @FileID OR ISNULL(@FileID, -1) = -1)
AND ms.ScoreID = 0
