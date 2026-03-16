CREATE PROCEDURE [dbo].[UpdateStagedGameKeys]

AS

BEGIN
	----Events
	UPDATE g
	SET g.EventName = e.EventID
	FROM stage.Games AS g
	INNER JOIN stage.Events AS e ON g.SourceName = e.SourceID
		AND g.EventName = e.EventName

	----WhitePlayerID
	UPDATE g
	SET g.WhitePlayerID = p.PlayerID
	FROM stage.Games AS g
	INNER JOIN stage.Players AS p ON g.SourceName = p.SourceID
		AND g.WhiteLast = p.LastName
		AND ISNULL(g.WhiteFirst, '') = ISNULL(p.FirstName, '')

	----BlackPlayerID
	UPDATE g
	SET g.BlackPlayerID = p.PlayerID
	FROM stage.Games AS g
	INNER JOIN stage.Players AS p ON g.SourceName = p.SourceID
		AND g.BlackLast = p.LastName
		AND ISNULL(g.BlackFirst, '') = ISNULL(p.FirstName, '')

	----TimeControl
	UPDATE g
	SET g.TimeControlDetail = t.TimeControlDetailID
	FROM stage.Games AS g
	INNER JOIN stage.TimeControlDetail AS t ON g.TimeControlDetail = t.TimeControlDetail
END
