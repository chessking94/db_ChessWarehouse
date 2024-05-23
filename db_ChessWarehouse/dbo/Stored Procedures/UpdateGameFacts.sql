CREATE PROCEDURE [dbo].[UpdateGameFacts]

AS

--add z-scores
DECLARE @mid tinyint = 1
DECLARE @mname varchar(15)
WHILE @mid <= (SELECT MAX(MeasurementID) FROM dim.Measurements)
BEGIN
	SELECT @mname = MeasurementName FROM dim.Measurements WHERE MeasurementID = @mid
	IF @mname IS NOT NULL AND (SELECT ScoreID FROM dim.Scores WHERE ScoreName = @mname) IS NULL  --there is a measurement name and it isn't a score
	BEGIN
		EXEC UpdateZScores @AggregationName = 'Game', @MeasurementName = @mname
		EXEC UpdateZScores @AggregationName = 'Game', @MeasurementName = @mname, @src = 'Personal', @src_stats = 'Control'
		EXEC UpdateZScores @AggregationName = 'Game', @MeasurementName = @mname, @src = 'PersonalOnline', @src_stats = 'Control'
	END
	SET @mid = @mid + 1
END

--add z-scores for fact.GameScores
SELECT
gs.SourceID,
gs.ColorID,
gs.ScoreID,
td.TimeControlID,
COUNT(gs.GameID) Ct_Score,
AVG(gs.Score) Avg_Score,
STDEV(gs.Score) SD_Score

INTO #tmpgamescores

FROM fact.GameScores gs
JOIN lake.Games g ON
	gs.GameID = g.GameID
JOIN dim.TimeControlDetail td ON
	g.TimeControlDetailID = td.TimeControlDetailID

GROUP BY
gs.SourceID,
gs.ColorID,
gs.ScoreID,
td.TimeControlID


UPDATE gs
SET gs.Score_Z = (CASE WHEN t.SD_Score = 0 THEN 0 ELSE (gs.Score - t.Avg_Score)/t.SD_Score END)
FROM fact.GameScores gs
JOIN lake.Games g ON
	gs.GameID = g.GameID
JOIN dim.TimeControlDetail td ON
	g.TimeControlDetailID = td.TimeControlDetailID
JOIN #tmpgamescores t ON
	gs.SourceID = t.SourceID
	AND gs.ColorID = t.ColorID
	AND gs.ScoreID = t.ScoreID
	AND td.TimeControlID = t.TimeControlID
WHERE gs.SourceID NOT IN (1, 2)

UPDATE gs
SET gs.Score_Z = (CASE WHEN t.SD_Score = 0 THEN 0 ELSE (gs.Score - t.Avg_Score)/t.SD_Score END)
FROM fact.GameScores gs
JOIN lake.Games g ON
	gs.GameID = g.GameID
JOIN #tmpgamescores t ON
	t.SourceID = 3
	AND gs.ColorID = t.ColorID
	AND gs.ScoreID = t.ScoreID
	AND t.TimeControlID = 5
WHERE gs.SourceID = 1

UPDATE gs
SET gs.Score_Z = (CASE WHEN t.SD_Score = 0 THEN 0 ELSE (gs.Score - t.Avg_Score)/t.SD_Score END)
FROM fact.GameScores gs
JOIN lake.Games g ON
	gs.GameID = g.GameID
JOIN dim.TimeControlDetail td ON
	g.TimeControlDetailID = td.TimeControlDetailID
JOIN #tmpgamescores t ON
	t.SourceID = 4
	AND gs.ColorID = t.ColorID
	AND gs.ScoreID = t.ScoreID
	AND td.TimeControlID = t.TimeControlID
WHERE gs.SourceID = 2


DROP TABLE #tmpgamescores


--add composite z-score
/*
	Methodology: Essentially a weighted average divided by the overall standard deviation
	Mathematics taken from https://stats.stackexchange.com/questions/348192/combining-z-scores-by-weighted-average-sanity-check-please
*/
DECLARE @T1_Weight decimal(5,4)
DECLARE @ScACPL_Weight decimal(5,4)
DECLARE @Score_Weight decimal(5,4)

SELECT
@T1_Weight = dbo.sqlSplit(Value, '|', 1),
@ScACPL_Weight = dbo.sqlSplit(Value, '|', 2),
@Score_Weight = dbo.sqlSplit(Value, '|', 3)

FROM dbo.Settings
WHERE ID = 11

IF (@T1_Weight + @ScACPL_Weight + @Score_Weight) <> 1
BEGIN
	DECLARE @err_msg nvarchar(100) = 'Z-Score weights do not sum to 1'
	RAISERROR(@err_msg, 1, 1)
	RETURN @err_msg
END


UPDATE gs
SET Composite_Z = (fg.T1_Z*@T1_Weight + fg.ScACPL_Z*@ScACPL_Weight + gs.Score_Z*@Score_Weight)/SQRT(POWER(@T1_Weight, 2) + POWER(@ScACPL_Weight, 2) + POWER(@Score_Weight, 2))
FROM fact.GameScores gs
JOIN fact.Game fg ON
	gs.SourceID = fg.SourceID
	AND gs.GameID = fg.GameID
	AND gs.ColorID = fg.ColorID
