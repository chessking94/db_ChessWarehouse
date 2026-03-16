CREATE PROCEDURE [dbo].[UpdateZScores] (
	@AggregationName VARCHAR(10)
	,@MeasurementName VARCHAR(15)
	,@src VARCHAR(15) = NULL
	,@src_stats VARCHAR(15) = NULL
)

AS

BEGIN
	DECLARE @aggid TINYINT = NULL
	DECLARE @mid TINYINT = NULL
	DECLARE @srcid TINYINT = NULL
	DECLARE @srcid_stats TINYINT = NULL
	DECLARE @basesql NVARCHAR(MAX)
	DECLARE @dsql NVARCHAR(MAX) = NULL
	DECLARE @vsql NVARCHAR(MAX)

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
INNER JOIN dim.Measurements AS m ON
	m.MeasurementID = ' + CONVERT(nvarchar(5), @mid) + N'
INNER JOIN stat.StatisticsSummary AS ss ON f.TimeControlID = ss.TimeControlID
	AND f.RatingID = ss.RatingID
	AND ss.MeasurementID = m.MeasurementID
	AND ss.AggregationID = ' + CONVERT(nvarchar(5), @aggid)

		IF @AggregationName = 'Game'
		BEGIN
			SET @basesql = @basesql + N'
	AND f.ColorID = ss.ColorID'
		END

		IF @AggregationName = 'Evaluation'
		BEGIN
			SET @basesql = @basesql + N'
	AND f.EvaluationGroupID = ss.EvaluationGroupID'
		END

		IF @srcid IS NULL OR @srcid_stats IS NULL
		BEGIN
			SET @dsql = N'
	AND f.SourceID = ss.SourceID'
		END
		ELSE
		BEGIN
			SET @dsql = N'
	AND f.SourceID = ' + CONVERT(nvarchar(5), @srcid) + N'
	AND ss.SourceID = ' + CONVERT(nvarchar(5), @srcid_stats)
		END
	
		SET @vsql = @basesql + @dsql
		--PRINT @vsql
		EXEC sp_executesql @vsql
	END
END
