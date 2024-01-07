CREATE PROCEDURE [dbo].[StageGames] (@fileid int = NULL)

AS

TRUNCATE TABLE stage.Games

INSERT INTO stage.Games (
	SourceName, 
	SiteName,
	SiteGameID,
	WhiteLast,
	WhiteFirst,
	BlackLast,
	BlackFirst,
	WhiteElo,
	BlackElo,
	TimeControlDetail,
	ECO_Code,
	GameDate,
	GameTime,
	EventName,
	RoundNum,
	Result,
	FileID
)

SELECT
Field1 AS SourceName,
Field2 AS SiteName,
Field3 AS SiteGameID,
Field4 AS WhiteLast,
Field5 AS WhiteFirst,
Field6 AS BlackLast,
Field7 AS BlackFirst,
Field8 AS WhiteElo,
Field9 AS BlackElo,
Field10 AS TimeControlDetail,
Field11 AS ECO_Code,
CASE WHEN ISDATE(Field12) = 1 THEN Field12 ELSE NULL END AS GameDate,
Field13 AS GameTime,
Field14 AS EventName,
Field15 AS RoundNum,
Field16 AS Result,
@fileid AS FileID

FROM stage.BulkInsertGameData

WHERE RecordKey = 'G'