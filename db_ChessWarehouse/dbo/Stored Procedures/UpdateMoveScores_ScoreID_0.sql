CREATE PROCEDURE [dbo].[UpdateMoveScores_ScoreID_0] (
	@FileID INT = NULL
)

AS

/*
	*** Score Name = TestScore ***
	This proc is intended to be used for score testing.
	It's main state is to set ms.ScoreValue and ms.MaxScoreValue to NULL.
*/

BEGIN
	UPDATE ms

	SET ms.ScoreValue = NULL
		,ms.MaxScoreValue = NULL

	FROM stat.MoveScores AS ms
	INNER JOIN lake.Moves AS m ON ms.GameID = m.GameID
		AND ms.MoveNumber = m.MoveNumber
		AND ms.ColorID = m.ColorID
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	LEFT JOIN FileHistory AS fh ON g.FileID = fh.FileID

	WHERE m.MoveScored = 1
	AND (fh.FileID = @FileID OR ISNULL(@FileID, -1) = -1)
	AND ms.ScoreID = 0
END
