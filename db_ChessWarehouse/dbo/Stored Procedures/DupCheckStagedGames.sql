CREATE PROCEDURE [dbo].[DupCheckStagedGames]

AS

/*
	Duplicate critera:
	Same source ID
	Same first and last names for White
	Same first and last names for Black
	Same game date
	Same event name
	Same round number
*/

BEGIN
	UPDATE stg

	SET stg.Errors = ISNULL(stg.Errors + '|', '') + 'Dup_' + CONVERT(VARCHAR(10), g.GameID)

	FROM lake.Games g
	INNER JOIN dim.Players w ON g.SourceID = w.SourceID
		AND g.WhitePlayerID = w.PlayerID
	INNER JOIN dim.Players b ON g.SourceID = b.SourceID
		AND g.BlackPlayerID = b.PlayerID
	INNER JOIN dim.Events e ON g.SourceID = e.SourceID
		AND g.EventID = e.EventID
	INNER JOIN stage.Games stg ON g.SourceID = stg.SourceName
		AND ISNULL(g.SiteID, 0) = ISNULL(stg.SiteName, '0')
		AND ISNULL(g.SiteGameID, '0') = ISNULL(stg.SiteGameID, '0')
		AND w.LastName = stg.WhiteLast
		AND ISNULL(w.FirstName, '') = ISNULL(stg.WhiteFirst, '')
		AND b.LastName = stg.BlackLast
		AND ISNULL(B.FirstName, '') = ISNULL(stg.BlackFirst, '')
		AND g.GameDate = stg.GameDate
		AND e.EventName = stg.EventName
		AND ISNULL(g.RoundNum, '') = ISNULL(stg.RoundNum, '')
END
