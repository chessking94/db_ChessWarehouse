CREATE PROCEDURE [dbo].[UpdateMoveScores] (
	@FileID INT
)

AS

BEGIN
	DECLARE @ForcedMoveThreshold DECIMAL(5,2) = CAST(dbo.GetSettingValue(1) AS DECIMAL(5,2))
	DECLARE @MaxEval DECIMAL(5,2) = CAST(dbo.GetSettingValue(3) AS DECIMAL(5,2))

	--TraceKey and MovesAnalyzed
	;WITH cte AS (
		SELECT
			m.GameID
			,m.MoveNumber
			,m.ColorID
			,ROW_NUMBER() OVER (PARTITION BY m.GameID, m.ColorID, LEFT(m.FEN, CHARINDEX(' ', m.FEN) - 1) ORDER BY m.MoveNumber) AS Position_Count

		FROM lake.Moves AS m
		INNER JOIN lake.Games AS g ON m.GameID = g.GameID
		INNER JOIN FileHistory AS fh ON g.FileID = fh.FileID

		WHERE fh.FileID = @FileID
	)

	UPDATE m
	SET m.TraceKey = (
			CASE
				WHEN m.IsTheory = 1 THEN 'b'  --book moves
				WHEN m.IsTablebase = 1 THEN 't'  --tablebase moves
				WHEN ISNULL(ABS(m.T1_Eval_POV), 100) > @MaxEval AND ISNULL(ABS(m.Move_Eval_POV), 100) > @MaxEval THEN 'e'  --eval is considered clearly winning; both are are to allow really bad blunders to be scored
				WHEN cte.Position_Count > 1 THEN 'r'  --repeated positions
				WHEN m.T2_Eval IS NULL OR (ABS((CASE WHEN LEFT(m.T1_Eval, 1) = '#' THEN 100 ELSE CAST(m.T1_Eval AS DECIMAL(5,2)) END) - (CASE WHEN LEFT(m.T2_Eval, 1) = '#' THEN 100 ELSE CAST(m.T2_Eval AS DECIMAL(5,2)) END)) > @ForcedMoveThreshold AND m.Move_Rank = 1) THEN 'f'  --forced moves
				WHEN m.Move_Rank = 1 THEN 'M'  --eval matches
				ELSE '0'  --move must have been subpar
			END
		)
		,m.MovesAnalyzed = (
			CASE
				WHEN m.T2_Eval IS NULL THEN 1
				WHEN m.T3_Eval IS NULL THEN 2
				WHEN m.T4_Eval IS NULL THEN 3
				WHEN m.T5_Eval IS NULL THEN 4
				WHEN m.T6_Eval IS NULL THEN 5
				WHEN m.T7_Eval IS NULL THEN 6
				WHEN m.T8_Eval IS NULL THEN 7
				WHEN m.T9_Eval IS NULL THEN 8
				WHEN m.T10_Eval IS NULL THEN 9
				ELSE 10
			END
		)

	FROM lake.Moves AS m
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	INNER JOIN FileHistory fh ON g.FileID = fh.FileID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID
	INNER JOIN cte ON m.GameID = cte.GameID
		AND m.MoveNumber = cte.MoveNumber
		AND m.ColorID = cte.ColorID

	WHERE fh.FileID = @FileID


	--MoveScored
	UPDATE m

	SET m.MoveScored = 1

	FROM lake.Moves AS m
	INNER JOIN dim.Traces AS t ON m.TraceKey = t.TraceKey
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	INNER JOIN FileHistory AS fh ON g.FileID = fh.FileID

	WHERE t.Scored = 1
	AND fh.FileID = @FileID


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

		IF @FileID IS NOT NULL SET @vsql = N'EXEC ' + @ScoreProc + ' ' + CONVERT(NVARCHAR(5), @FileID)
		ELSE SET @vsql = N'EXEC ' + @ScoreProc

		--PRINT @vsql
		EXEC sp_executesql @vsql

		DELETE FROM #activescoreid WHERE ScoreID = @ScoreID
		SET @ScoreID = (SELECT TOP 1 ScoreID FROM #activescoreid)
	ENd

	DROP TABLE #activescoreid
END
