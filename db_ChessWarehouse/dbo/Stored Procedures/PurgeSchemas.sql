CREATE PROCEDURE [dbo].[PurgeSchemas] (
	@stage BIT = 0
	,@dim BIT = 0
	,@lake BIT = 0
	,@fact BIT = 0
)

AS

BEGIN
	PRINT 'Purge is no longer available.'
	--IF @stage = 1
	--BEGIN
	--	EXEC dbo.DeleteStagedGameData @errors = 0
	--END

	--IF @fact = 1
	--BEGIN
	--	TRUNCATE TABLE fact.Event
	--	TRUNCATE TABLE fact.Game
	--END

	--IF @lake = 1
	--BEGIN
	--	TRUNCATE TABLE lake.Moves
	--	DELETE FROM lake.Games
	--	DBCC CHECKIDENT('lake.Games', RESEED, 0)
	--END

	--IF @dim = 1
	--BEGIN
	--	DELETE FROM dim.Events
	--	DBCC CHECKIDENT('dim.Events', RESEED, 0)
	--	DELETE FROM dim.Players WHERE SelfFlag = 0  --don't delete my personal records!
	--	DBCC CHECKIDENT('dim.Players', RESEED, 7)  --if I ever have other online accountS, I won't be running this purge anymore. OK to hard-code an ID to start at
	--	DELETE FROM dim.TimeControlDetail
	--	DBCC CHECKIDENT('dim.TimeControlDetail', RESEED, 0)
	--END
END
