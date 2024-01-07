
CREATE VIEW [lake].[vwEventBreakdown]

AS

SELECT
GameID,
'White' AS Color,
WhitePlayerID AS PlayerID,
WhiteElo AS Elo,
BlackPlayerID AS OppPlayerID,
BlackElo AS OppElo,
ECOID,
GameDate,
EventID,
RoundNum,
Result AS ColorResult

FROM lake.Games

UNION

SELECT
GameID,
'Black' AS Color,
BlackPlayerID AS PlayerID,
BlackElo AS Elo,
WhitePlayerID AS OppPlayerID,
WhiteElo AS OppElo,
ECOID,
GameDate,
EventID,
RoundNum,
CASE WHEN Result = 0.5 THEN Result ELSE 1 - Result END AS ColorResult

FROM lake.Games
