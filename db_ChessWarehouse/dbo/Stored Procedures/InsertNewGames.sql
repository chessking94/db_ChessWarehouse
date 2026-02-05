CREATE PROCEDURE [dbo].[InsertNewGames] (
	@AnalysisStatusID TINYINT
)

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
	FileID,
	AnalysisStatusID
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
FileID,
@AnalysisStatusID AS AnalysisStatusID

FROM stage.Games
