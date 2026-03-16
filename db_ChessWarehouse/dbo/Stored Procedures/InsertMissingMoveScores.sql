CREATE PROCEDURE [dbo].[InsertMissingMoveScores]

AS

BEGIN
	INSERT INTO stat.MoveScores (
		ScoreID
		,GameID
		,MoveNumber
		,ColorID
	)

	SELECT
		sc.ScoreID
		,m.GameID
		,m.MoveNumber
		,m.ColorID

	FROM lake.Moves AS m
	CROSS JOIN dim.Scores AS sc
	LEFT JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
		AND m.MoveNumber = ms.MoveNumber
		AND m.ColorID = ms.ColorID
		AND ms.ScoreID = sc.ScoreID

	WHERE sc.ScoreActive = 1
	AND ms.ScoreID IS NULL
END
