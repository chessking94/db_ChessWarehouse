CREATE PROCEDURE CreateScoreViews

AS

DECLARE @viewname nvarchar(MAX)
DECLARE @columns nvarchar(MAX)
DECLARE @sql nvarchar(MAX)
DECLARE	@viewsql nvarchar(MAX)

--event
SET @viewname = 'fact.vwEventScoresPivot'
SET @columns = NULL
SET @sql = N'DROP VIEW ' + @viewname
SET @viewsql = NULL

IF (OBJECT_ID(@viewname) IS NOT NULL) EXEC sp_executesql @sql
SELECT @columns = COALESCE(@columns + ', ', '') + QUOTENAME(ScoreName) FROM (SELECT ScoreName FROM dim.Scores) AS PivotColumns

SET @sql = N'
SELECT
pt.*

FROM (
	SELECT
	es.EventID,
	es.SourceID,
	es.TimeControlID,
	es.PlayerID,
	sc.ScoreName,
	es.Score
	FROM fact.EventScores es
	JOIN dim.Scores sc ON es.ScoreID = sc.ScoreID
) s
PIVOT (
	SUM(s.Score) FOR s.ScoreName IN (' + @columns + ')
) AS pt
'

SET @viewsql = N'CREATE VIEW ' + @viewname + N' AS' + CHAR(13) + @sql

--PRINT @viewsql
EXEC sp_executesql @viewsql


--game
SET @viewname = 'fact.vwGameScoresPivot'
SET @columns = NULL
SET @sql = N'DROP VIEW ' + @viewname
SET @viewsql = NULL

IF (OBJECT_ID(@viewname) IS NOT NULL) EXEC sp_executesql @sql
SELECT @columns = COALESCE(@columns + ', ', '') + QUOTENAME(ScoreName) FROM (SELECT ScoreName FROM dim.Scores) AS PivotColumns

SET @sql = N'
SELECT
pt.*

FROM (
	SELECT
	gs.SourceID,
	gs.GameID,
	gs.ColorID,
	sc.ScoreName,
	gs.Score
	FROM fact.GameScores gs
	JOIN dim.Scores sc ON gs.ScoreID = sc.ScoreID
) s
PIVOT (
	SUM(s.Score) FOR s.ScoreName IN (' + @columns + ')
) AS pt
'

SET @viewsql = N'CREATE VIEW ' + @viewname + N' AS' + CHAR(13) + @sql

--PRINT @viewsql
EXEC sp_executesql @viewsql


--evaluation
SET @viewname = 'fact.vwEvaluationScoresPivot'
SET @columns = NULL
SET @sql = N'DROP VIEW ' + @viewname
SET @viewsql = NULL

IF (OBJECT_ID(@viewname) IS NOT NULL) EXEC sp_executesql @sql
SELECT @columns = COALESCE(@columns + ', ', '') + QUOTENAME(ScoreName) FROM (SELECT ScoreName FROM dim.Scores) AS PivotColumns

SET @sql = N'
SELECT
pt.*

FROM (
	SELECT
	es.SourceID,
	es.EvaluationGroupID,
	es.RatingID,
	es.TimeControlID,
	sc.ScoreName,
	es.Score
	FROM fact.EvaluationScores es
	JOIN dim.Scores sc ON es.ScoreID = sc.ScoreID
) s
PIVOT (
	SUM(s.Score) FOR s.ScoreName IN (' + @columns + ')
) AS pt
'

SET @viewsql = N'CREATE VIEW ' + @viewname + N' AS' + CHAR(13) + @sql

--PRINT @viewsql
EXEC sp_executesql @viewsql
