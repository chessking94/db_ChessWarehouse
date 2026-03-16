CREATE PROCEDURE [dbo].[UpdateGameData] (
	@fileid INT
)

AS

BEGIN
	--White berserks
	UPDATE g

	SET g.WhiteBerserk = 1

	FROM lake.Games AS g
	INNER JOIN lake.Moves AS m ON g.GameID = m.GameID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID
	INNER JOIN dim.TimeControlDetail AS td ON g.TimeControlDetailID = td.TimeControlDetailID
	INNER JOIN dim.TimeControls AS tc ON td.TimeControlID = tc.TimeControlID

	WHERE m.MoveNumber = 1
	AND c.Color = 'White'
	AND td.Seconds IS NOT NULL
	AND m.Clock*2 <= td.Seconds
	AND g.FileID = @fileid


	--Black berserks
	UPDATE g

	SET g.BlackBerserk = 1

	FROM lake.Games AS g
	INNER JOIN lake.Moves AS m ON g.GameID = m.GameID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID
	INNER JOIN dim.TimeControlDetail AS td ON g.TimeControlDetailID = td.TimeControlDetailID
	INNER JOIN dim.TimeControls AS tc ON td.TimeControlID = tc.TimeControlID

	WHERE m.MoveNumber = 1
	AND c.Color = 'Black'
	AND td.Seconds IS NOT NULL
	AND m.Clock*2 <= td.Seconds
	AND g.FileID = @fileid
END
