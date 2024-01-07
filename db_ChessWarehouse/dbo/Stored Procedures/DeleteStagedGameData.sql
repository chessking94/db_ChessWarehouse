CREATE PROCEDURE dbo.DeleteStagedGameData (@errors int)

AS

TRUNCATE TABLE stage.BulkInsertGameData
TRUNCATE TABLE stage.Events
TRUNCATE TABLE stage.Players
TRUNCATE TABLE stage.TimeControlDetail

IF @errors > 0
BEGIN
	DELETE FROM stage.Games WHERE Errors IS NULL
	DELETE FROM stage.Moves WHERE Errors IS NULL
END
ELSE
BEGIN
	TRUNCATE TABLE stage.Games
	TRUNCATE TABLE stage.Moves
END