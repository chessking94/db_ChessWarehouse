CREATE PROCEDURE [dbo].[UpdateStagedMoveKeys]

AS

UPDATE m
SET m.GameID = lg.GameID
FROM stage.Moves m
JOIN stage.Games sg ON m.SiteGameID = sg.SiteGameID
JOIN lake.Games lg ON sg.SourceName = lg.SourceID AND ISNULL(sg.SiteName, '') = ISNULL(lg.SiteID, '') AND sg.SiteGameID = lg.SiteGameID
