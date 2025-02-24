CREATE PROCEDURE [dbo].[FormatGameData]

AS

--general updates
UPDATE g
SET g.SiteName = s.SiteID
FROM stage.Games g
LEFT JOIN dim.Sites s ON g.SiteName = s.SiteName

UPDATE g
SET g.WhiteElo = 0
FROM stage.Games g
WHERE g.WhiteElo IS NULL

UPDATE g
SET g.BlackElo = 0
FROM stage.Games g
WHERE g.BlackElo IS NULL

UPDATE g
SET g.RoundNum = CASE WHEN LEFT(g.RoundNum, 1) LIKE '[1-9]' THEN FLOOR(CAST(g.RoundNum AS float)) ELSE NULL END
FROM stage.Games g

UPDATE g
SET g.EventRated = 1
FROM stage.Games g
WHERE g.EventRated IS NULL OR g.EventRated NOT IN ('0', '1')

--errors
UPDATE g
SET g.SourceName = s.SourceID, g.Errors = (CASE WHEN s.SourceID IS NULL THEN 'SourceName' ELSE NULL END)
FROM stage.Games g
LEFT JOIN dim.Sources s ON g.SourceName = s.SourceName

UPDATE g
SET g.Errors = ISNULL(g.Errors + '|', '') + 'WhiteLast'
FROM stage.Games g
WHERE g.WhiteLast IS NULL

UPDATE g
SET g.Errors = ISNULL(g.Errors + '|', '') + 'BlackLast'
FROM stage.Games g
WHERE g.BlackLast IS NULL

UPDATE g
SET g.ECO_Code = e.ECOID, g.Errors = (CASE WHEN e.ECOID IS NULL THEN ISNULL(g.Errors + '|', '') + 'ECO_Code' ELSE g.Errors END)
FROM stage.Games g
LEFT JOIN dim.ECO e ON ISNULL(g.ECO_Code, 'A00') = e.ECO_Code

UPDATE g
SET g.Errors = ISNULL(g.Errors + '|', '') + 'GameDate'
FROM stage.Games g
WHERE g.GameDate IS NULL

UPDATE g
SET g.Errors = ISNULL(g.Errors + '|', '') + 'EventName'
FROM stage.Games g
WHERE g.EventName IS NULL

UPDATE g
SET g.Result = NULL, g.Errors = ISNULL(g.Errors + '|', '') + 'Result'
FROM stage.Games g
WHERE ISNULL(g.Result, '') NOT IN ('0.0', '0.5', '1.0')
