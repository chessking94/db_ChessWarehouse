CREATE PROCEDURE [dbo].[UpdateMoveScores_ScoreID_0] (@FileID int = NULL)

AS

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
