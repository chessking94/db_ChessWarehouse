CREATE PROCEDURE [dbo].[UpdateEventFacts]

AS

--add z-scores
DECLARE @mid tinyint = 1
DECLARE @mname varchar(15)
WHILE @mid <= 10
BEGIN
	SELECT @mname = MeasurementName FROM dim.Measurements WHERE MeasurementID = @mid
	EXEC UpdateZScores @AggregationName = 'Event', @MeasurementName = @mname
	EXEC UpdateZScores @AggregationName = 'Event', @MeasurementName = @mname, @src = 'Personal', @src_stats = 'Control'
	--EXEC UpdateZScores @AggregationName = 'Game', @MeasurementName = @mname, @src = 'PersonalOnline', @src_stats = 'Control'
	SET @mid = @mid + 1
END


--add composite z-scores
/*
	Methodology: Essentially a weighted average divided by the overall standard deviation
	Mathematics taken from https://stats.stackexchange.com/questions/348192/combining-z-scores-by-weighted-average-sanity-check-please
*/
DECLARE @T1_Weight decimal(5,4) = 0.2
DECLARE @ScACPL_Weight decimal(5,4) = 0.35
DECLARE @Score_Weight decimal(5,4) = 0.45

UPDATE fact.Event
SET Composite_Z = (T1_Z*@T1_Weight + ScACPL_Z*@ScACPL_Weight + Score_Z*@Score_Weight)/SQRT(POWER(@T1_Weight, 2) + POWER(@ScACPL_Weight, 2) + POWER(@Score_Weight, 2))


--add z-scores for fact.EventScores
SELECT
SourceID,
TimeControlID,
ScoreID,
COUNT(EventID) Ct_Score,
AVG(Score) Avg_Score,
STDEV(Score) SD_Score

INTO #tmpeventscores

FROM fact.EventScores

GROUP BY
SourceID,
TimeControlID,
ScoreID


UPDATE es
SET es.Score_Z = (CASE WHEN t.SD_Score = 0 THEN 0 ELSE (es.Score - t.Avg_Score)/t.SD_Score END)
FROM fact.EventScores es
JOIN #tmpeventscores t ON
	es.SourceID = t.SourceID AND
	es.TimeControlID = t.TimeControlID AND
	es.ScoreID = t.ScoreID
WHERE es.SourceID NOT IN (1, 2)

UPDATE es
SET es.Score_Z = (CASE WHEN t.SD_Score = 0 THEN 0 ELSE (es.Score - t.Avg_Score)/t.SD_Score END)
FROM fact.EventScores es
JOIN #tmpeventscores t ON
	t.SourceID = 3 AND
	t.TimeControlID = 5 AND
	es.ScoreID = t.ScoreID
WHERE es.SourceID = 1


DROP TABLE #tmpeventscores

