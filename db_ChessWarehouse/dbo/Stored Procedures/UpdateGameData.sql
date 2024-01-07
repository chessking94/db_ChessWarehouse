CREATE PROCEDURE UpdateGameData (@fileid int)

AS

--White berserks
UPDATE g
SET g.WhiteBerserk = 1

FROM lake.Games g
JOIN lake.Moves m ON g.GameID = m.GameID
JOIN dim.Colors c ON m.ColorID = c.ColorID
JOIN dim.TimeControlDetail td ON g.TimeControlDetailID = td.TimeControlDetailID
JOIN dim.TimeControls tc ON td.TimeControlID = tc.TimeControlID

WHERE m.MoveNumber = 1
AND c.Color = 'White'
AND td.Seconds IS NOT NULL
AND m.Clock*2 <= td.Seconds
AND g.FileID = @fileid


--Black berserks
UPDATE g
SET g.BlackBerserk = 1

FROM lake.Games g
JOIN lake.Moves m ON g.GameID = m.GameID
JOIN dim.Colors c ON m.ColorID = c.ColorID
JOIN dim.TimeControlDetail td ON g.TimeControlDetailID = td.TimeControlDetailID
JOIN dim.TimeControls tc ON td.TimeControlID = tc.TimeControlID

WHERE m.MoveNumber = 1
AND c.Color = 'Black'
AND td.Seconds IS NOT NULL
AND m.Clock*2 <= td.Seconds
AND g.FileID = @fileid