CREATE PROCEDURE [dbo].[UpdateStagedMoveKeys]

AS

BEGIN
	----GameID
	UPDATE m

	SET m.GameID = lg.GameID

	FROM stage.Moves AS m
	INNER JOIN stage.Games AS sg ON m.SiteGameID = sg.SiteGameID
	INNER JOIN lake.Games AS lg ON sg.SourceName = lg.SourceID
		AND ISNULL(sg.SiteName, '') = ISNULL(lg.SiteID, '')
		AND sg.SiteGameID = lg.SiteGameID

	----EngineID
	UPDATE m

	SET m.EngineName = eng.EngineID

	FROM stage.Moves AS m
	INNER JOIN dim.Engines AS eng ON m.EngineName = eng.EngineName
END
