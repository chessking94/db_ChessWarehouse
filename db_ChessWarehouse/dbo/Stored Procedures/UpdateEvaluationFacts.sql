CREATE PROCEDURE [dbo].[UpdateEvaluationFacts]

AS

BEGIN
	--add z-scores
	DECLARE @mid TINYINT = 1
	DECLARE @mname VARCHAR(15)
	WHILE @mid <= (SELECT MAX(MeasurementID) FROM dim.Measurements)
	BEGIN
		SELECT @mname = MeasurementName FROM dim.Measurements WHERE MeasurementID = @mid
		IF @mname IS NOT NULL AND (SELECT ScoreID FROM dim.Scores WHERE ScoreName = @mname) IS NULL  --there is a measurement name and it isn't a score
		BEGIN
			EXEC UpdateZScores @AggregationName = 'Evaluation', @MeasurementName = @mname
			EXEC UpdateZScores @AggregationName = 'Evaluation', @MeasurementName = @mname, @src = 'Personal', @src_stats = 'Control'
			EXEC UpdateZScores @AggregationName = 'Evaluation', @MeasurementName = @mname, @src = 'PersonalOnline', @src_stats = 'Control'
		END
		SET @mid = @mid + 1
	END

	--TODO: TBD if there's a reasonable way to do z-scores here, since the data is already aggregated there might not be one

	--add composite z-score
	/*
		Methodology: Essentially a weighted average divided by the overall standard deviation
		Mathematics taken from https://stats.stackexchange.com/questions/348192/combining-z-scores-by-weighted-average-sanity-check-please
	*/
	DECLARE @T1_Weight DECIMAL(5,4)
	DECLARE @ScACPL_Weight DECIMAL(5,4)
	DECLARE @Score_Weight DECIMAL(5,4)

	SELECT
		@T1_Weight = dbo.sqlSplit(Value, '|', 1)
		,@ScACPL_Weight = dbo.sqlSplit(Value, '|', 2)
		,@Score_Weight = dbo.sqlSplit(Value, '|', 3)

	FROM dbo.Settings

	WHERE ID = 11

	IF (@T1_Weight + @ScACPL_Weight + @Score_Weight) <> 1
	BEGIN
		DECLARE @err_msg NVARCHAR(100) = 'Z-Score weights do not sum to 1'
		RAISERROR(@err_msg, 1, 1)
		RETURN @err_msg
	END


	UPDATE es

	SET Composite_Z = (fe.T1_Z*@T1_Weight + fe.ScACPL_Z*@ScACPL_Weight + es.Score_Z*@Score_Weight)/SQRT(POWER(@T1_Weight, 2) + POWER(@ScACPL_Weight, 2) + POWER(@Score_Weight, 2))

	FROM fact.EvaluationScores AS es
	INNER JOIN fact.Evaluation AS fe ON es.SourceID = fe.SourceID
		AND es.EvaluationGroupID = fe.EvaluationGroupID
		AND es.TimeControlID = fe.TimeControlID
		AND es.RatingID = fe.RatingID
END
