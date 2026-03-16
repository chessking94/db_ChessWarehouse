CREATE PROCEDURE [dbo].[CreateScoreViews]

AS

BEGIN
	DECLARE @ScriptOnly BIT = 0
	DECLARE @viewname NVARCHAR(MAX)
	DECLARE @columns NVARCHAR(MAX)
	DECLARE @sql NVARCHAR(MAX)
	DECLARE	@viewsql NVARCHAR(MAX)

	--event
	SET @viewname = 'fact.vwEventScoresPivot'
	SET @columns = NULL
	SET @sql = N'DROP VIEW ' + @viewname
	SET @viewsql = NULL

	IF @ScriptOnly = 0
	BEGIN
		IF (OBJECT_ID(@viewname) IS NOT NULL) EXEC sp_executesql @sql
	END
	SELECT @columns = COALESCE(@columns + ', ', '') + QUOTENAME(ScoreName) FROM (SELECT ScoreName FROM dim.Scores) AS PivotColumns

	SET @sql = N'
	SELECT
	pt.*

	FROM (
		SELECT
			es.EventID
			,es.SourceID
			,es.TimeControlID
			,es.PlayerID
			,sc.ScoreName
			,es.Score

		FROM fact.EventScores AS es

		INNER JOIN dim.Scores AS sc ON es.ScoreID = sc.ScoreID
	) s
	PIVOT (
		SUM(s.Score) FOR s.ScoreName IN (' + @columns + ')
	) AS pt
	'

	SET @viewsql = N'CREATE VIEW ' + @viewname + N' AS' + CHAR(13) + @sql

	IF @ScriptOnly = 1
	BEGIN
		PRINT (CHAR(13) + CHAR(13))
		PRINT @viewsql
	END
	ELSE
	BEGIN
		EXEC sp_executesql @viewsql
	END

	--game
	SET @viewname = 'fact.vwGameScoresPivot'
	SET @columns = NULL
	SET @sql = N'DROP VIEW ' + @viewname
	SET @viewsql = NULL

	IF @ScriptOnly = 0
	BEGIN
		IF (OBJECT_ID(@viewname) IS NOT NULL) EXEC sp_executesql @sql
	END
	SELECT @columns = COALESCE(@columns + ', ', '') + QUOTENAME(ScoreName) FROM (SELECT ScoreName FROM dim.Scores) AS PivotColumns

	SET @sql = N'
	SELECT
	pt.*

	FROM (
		SELECT
			gs.SourceID
			,gs.GameID
			,gs.ColorID
			,sc.ScoreName
			,gs.Score

		FROM fact.GameScores AS gs
		INNER JOIN dim.Scores AS sc ON gs.ScoreID = sc.ScoreID
	) s
	PIVOT (
		SUM(s.Score) FOR s.ScoreName IN (' + @columns + ')
	) AS pt
	'

	SET @viewsql = N'CREATE VIEW ' + @viewname + N' AS' + CHAR(13) + @sql

	IF @ScriptOnly = 1
	BEGIN
		PRINT (CHAR(13) + CHAR(13))
		PRINT @viewsql
	END
	ELSE
	BEGIN
		EXEC sp_executesql @viewsql
	END

	--evaluation
	SET @viewname = 'fact.vwEvaluationScoresPivot'
	SET @columns = NULL
	SET @sql = N'DROP VIEW ' + @viewname
	SET @viewsql = NULL

	IF @ScriptOnly = 0
	BEGIN
		IF (OBJECT_ID(@viewname) IS NOT NULL) EXEC sp_executesql @sql
	END
	SELECT @columns = COALESCE(@columns + ', ', '') + QUOTENAME(ScoreName) FROM (SELECT ScoreName FROM dim.Scores) AS PivotColumns

	SET @sql = N'
	SELECT
	pt.*

	FROM (
		SELECT
			es.SourceID
			,es.EvaluationGroupID
			,es.RatingID
			,es.TimeControlID
			,sc.ScoreName
			,es.Score

		FROM fact.EvaluationScores AS es
		INNER JOIN dim.Scores AS sc ON es.ScoreID = sc.ScoreID
	) s
	PIVOT (
		SUM(s.Score) FOR s.ScoreName IN (' + @columns + ')
	) AS pt
	'

	SET @viewsql = N'CREATE VIEW ' + @viewname + N' AS' + CHAR(13) + @sql

	IF @ScriptOnly = 1
	BEGIN
		PRINT (CHAR(13) + CHAR(13))
		PRINT @viewsql
	END
	ELSE
	BEGIN
		EXEC sp_executesql @viewsql
	END
END
