CREATE PROCEDURE [dbo].[UpdateMoveScoresAll]

AS

BEGIN
	--stat.MoveScores
	DECLARE @ScoreID TINYINT
	DECLARE @vsql NVARCHAR(MAX)
	DECLARE @ScoreProc NVARCHAR(MAX)	

	CREATE TABLE #activescoreid (ScoreID TINYINT NOT NULL)
	INSERT INTO #activescoreid
	SELECT ScoreID FROM dim.Scores WHERE ScoreActive = 1

	SET @ScoreID = (SELECT TOP 1 ScoreID FROM #activescoreid)
	WHILE @ScoreID IS NOT NULL
	BEGIN
		SET @ScoreProc = (SELECT ScoreProc FROM dim.Scores WHERE ScoreID = @ScoreID)
		SET @vsql = N'EXEC ' + @ScoreProc

		--PRINT @vsql
		EXEC sp_executesql @vsql

		DELETE FROM #activescoreid WHERE ScoreID = @ScoreID
		SET @ScoreID = (SELECT TOP 1 ScoreID FROM #activescoreid)
	END

	DROP TABLE #activescoreid
END
