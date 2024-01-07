CREATE PROCEDURE [dbo].[PurgeSchemas] (@stage bit = 0, @dim bit = 0, @lake bit = 0, @fact bit = 0)

AS

IF @stage = 1
BEGIN
	EXEC dbo.DeleteStagedGameData @errors = 0
END

IF @fact = 1
BEGIN
	TRUNCATE TABLE fact.Event
	TRUNCATE TABLE fact.Game
END

IF @lake = 1
BEGIN
	TRUNCATE TABLE lake.Moves
	DELETE FROM lake.Games
	DBCC CHECKIDENT('lake.Games', RESEED, 0)
END

IF @dim = 1
BEGIN
	DELETE FROM dim.Events
	DBCC CHECKIDENT('dim.Events', RESEED, 0)
	DELETE FROM dim.Players WHERE SelfFlag = 0 --don't delete my personal records!
	DBCC CHECKIDENT('dim.Players', RESEED, 7) --if I ever have other online account, I won't be running this purge anymore. OK to hard-code an ID to start at
	DELETE FROM dim.TimeControlDetail
	DBCC CHECKIDENT('dim.TimeControlDetail', RESEED, 0)
END