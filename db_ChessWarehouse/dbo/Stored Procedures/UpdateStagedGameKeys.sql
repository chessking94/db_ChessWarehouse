CREATE PROCEDURE dbo.UpdateStagedGameKeys

AS

----Events
UPDATE g
SET g.EventName = e.EventID
FROM stage.Games g
JOIN stage.Events e ON g.SourceName = e.SourceID AND g.EventName = e.EventName

----WhitePlayerID
UPDATE g
SET g.WhitePlayerID = p.PlayerID
FROM stage.Games g
JOIN stage.Players p ON g.SourceName = p.SourceID AND g.WhiteLast = p.LastName AND ISNULL(g.WhiteFirst, '') = ISNULL(p.FirstName, '')

----BlackPlayerID
UPDATE g
SET g.BlackPlayerID = p.PlayerID
FROM stage.Games g
JOIN stage.Players p ON g.SourceName = p.SourceID AND g.BlackLast = p.LastName AND ISNULL(g.BlackFirst, '') = ISNULL(p.FirstName, '')

----TimeControl
UPDATE g
SET g.TimeControlDetail = t.TimeControlDetailID
FROM stage.Games g
JOIN stage.TimeControlDetail t ON g.TimeControlDetail = t.TimeControlDetail
