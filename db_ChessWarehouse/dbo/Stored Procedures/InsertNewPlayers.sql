CREATE PROCEDURE dbo.InsertNewPlayers

AS

BEGIN
	--stage
	INSERT INTO stage.Players (SourceID, LastName, FirstName)
	SELECT SourceName, WhiteLast, WhiteFirst FROM stage.Games
	UNION
	SELECT SourceName, BlackLast, BlackFirst FROM stage.Games

	UPDATE stg
	SET stg.PlayerID = prod.PlayerID
	FROM stage.Players AS stg
	INNER JOIN dim.Players AS prod ON stg.SourceID = prod.SourceID 
		AND stg.LastName = prod.LastName
		AND ISNULL(stg.FirstName, '') = ISNULL(prod.FirstName, '')


	--insert
	INSERT INTO dim.Players (SourceID, LastName, FirstName)
	SELECT SourceID, LastName, FirstName FROM stage.Players WHERE PlayerID IS NULL

	UPDATE stg
	SET stg.PlayerID = prod.PlayerID
	FROM stage.Players AS stg
	INNER JOIN dim.Players AS prod ON stg.SourceID = prod.SourceID
		AND stg.LastName = prod.LastName
		AND ISNULL(stg.FirstName, '') = ISNULL(prod.FirstName, '')
	WHERE stg.PlayerID IS NULL
END
