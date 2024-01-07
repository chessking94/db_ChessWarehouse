CREATE PROCEDURE [dbo].[InsertNewGames]

AS

INSERT INTO lake.Games (
	SourceID,
	SiteID,
	SiteGameID,
	WhitePlayerID,
	BlackPlayerID,
	WhiteElo,
	BlackElo,
	TimeControlDetailID,
	ECOID,
	GameDate,
	GameTime,
	EventID,
	RoundNum,
	Result,
	FileID
)

SELECT
SourceName AS SourceID,
SiteName AS SiteID,
SiteGameID,
WhitePlayerID,
BlackPlayerID,
WhiteElo,
BlackElo,
TimeControlDetail AS TimeControlDetailID,
ECO_Code AS ECOID,
GameDate,
GameTime,
EventName AS EventID,
RoundNum,
Result,
FileID

FROM stage.Games