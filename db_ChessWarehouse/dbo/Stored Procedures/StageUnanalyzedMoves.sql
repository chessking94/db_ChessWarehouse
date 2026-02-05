CREATE PROCEDURE dbo.StageUnanalyzedMoves

AS

TRUNCATE TABLE stage.Moves

INSERT INTO stage.Moves (
	SiteGameID,
	MoveNumber,
	Color,
	Clock,
	TimeSpent,
	FEN,
	PhaseID,
	Move
)

SELECT
Field1 AS SiteGameID,
Field2 AS MoveNumber,
Field3 AS Color,
Field4 AS Clock,
Field5 AS TimeSpent,
Field6 AS FEN,
Field7 AS PhaseID,
Field8 AS Move

FROM stage.BulkInsertUnanalyzedGames

WHERE RecordKey = 'M'
