CREATE PROCEDURE [dbo].[UpdateZScores] (@AggregationName varchar(10), @MeasurementName varchar(15), @src varchar(15) = NULL, @src_stats varchar(15) = NULL)

AS

DECLARE @aggid tinyint = NULL
DECLARE @mid tinyint = NULL
DECLARE @srcid tinyint = NULL
DECLARE @srcid_stats tinyint = NULL
DECLARE @basesql nvarchar(MAX)
DECLARE @dsql nvarchar(MAX) = NULL
DECLARE @vsql nvarchar(MAX)

SELECT @aggid = AggregationID FROM dim.Aggregations WHERE AggregationName = @AggregationName
SELECT @mid = MeasurementID FROM dim.Measurements WHERE MeasurementName = @MeasurementName
SELECT @srcid = SourceID FROM dim.Sources WHERE SourceName = @src
SELECT @srcid_stats = SourceID FROM dim.Sources WHERE SourceName = @src_stats

IF @aggid IS NOT NULL AND @mid IS NOT NULL
BEGIN
	SET @basesql = N'
UPDATE f
SET f.' + @MeasurementName + N'_Z = CASE WHEN ss.Average IS NULL THEN NULL WHEN ss.StandardDeviation = 0 THEN 0 ELSE m.ZScore_Multiplier*(f.' + @MeasurementName + N' - ss.Average)/ss.StandardDeviation END
FROM fact.' + @AggregationName + N' f
JOIN dim.Measurements m ON
	m.MeasurementID = ' + CONVERT(nvarchar(5), @mid) + N'
JOIN stat.StatisticsSummary ss ON
	f.TimeControlID = ss.TimeControlID AND
	f.RatingID = ss.RatingID AND
	ss.MeasurementID = m.MeasurementID AND
	ss.AggregationID = ' + CONVERT(nvarchar(5), @aggid) + N' AND'

	IF @AggregationName = 'Game'
	BEGIN
		SET @basesql = @basesql + N'
	f.ColorID = ss.ColorID AND'
	END

	IF @AggregationName = 'Evaluation'
	BEGIN
		SET @basesql = @basesql + N'
	f.EvaluationGroupID = ss.EvaluationGroupID AND'
	END

	IF @srcid IS NULL OR @srcid_stats IS NULL
	BEGIN
		SET @dsql = N'
	f.SourceID = ss.SourceID'
	END
	ELSE
	BEGIN
		SET @dsql = N'
	f.SourceID = ' + CONVERT(nvarchar(5), @srcid) + N' AND
	ss.SourceID = ' + CONVERT(nvarchar(5), @srcid_stats)
	END
	
	SET @vsql = @basesql + @dsql
	--PRINT @vsql
	EXEC sp_executesql @vsql
END
