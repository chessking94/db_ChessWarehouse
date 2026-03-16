CREATE PROCEDURE [dbo].[InsertNewEvents]

AS

BEGIN
	--stage
	INSERT INTO stage.Events (SourceID, EventName, EventRated)
	SELECT DISTINCT SourceName, EventName, EventRated FROM stage.Games

	UPDATE stg
	SET stg.EventID = prod.EventID
	FROM stage.Events AS stg
	INNER JOIN dim.Events AS prod ON stg.SourceID = prod.SourceID
		AND stg.EventName = prod.EventName


	--insert
	INSERT INTO dim.Events (SourceID, EventName, EventRated)
	SELECT SourceID, EventName, EventRated FROM stage.Events WHERE EventID IS NULL

	UPDATE stg
	SET stg.EventID = prod.EventID
	FROM stage.Events AS stg
	INNER JOIN dim.Events AS prod ON stg.SourceID = prod.SourceID
		AND stg.EventName = prod.EventName
	WHERE stg.EventID IS NULL
END
