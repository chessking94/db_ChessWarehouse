CREATE PROCEDURE [dbo].[UpdateMoveScoresAll]

AS

--stat.MoveScores
DECLARE @ScoreID tinyint
DECLARE @vsql nvarchar(MAX)
DECLARE @ScoreProc nvarchar(MAX)	

CREATE TABLE #activescoreid (ScoreID tinyint NOT NULL)
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
ENd

DROP TABLE #activescoreid
