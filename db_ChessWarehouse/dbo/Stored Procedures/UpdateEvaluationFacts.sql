CREATE PROCEDURE [dbo].[UpdateEvaluationFacts]

AS

--add z-scores
DECLARE @mid tinyint = 1
DECLARE @mname varchar(15)
WHILE @mid <= 10
BEGIN
	SELECT @mname = MeasurementName FROM dim.Measurements WHERE MeasurementID = @mid
	EXEC UpdateZScores @AggregationName = 'Evaluation', @MeasurementName = @mname
	EXEC UpdateZScores @AggregationName = 'Evaluation', @MeasurementName = @mname, @src = 'Personal', @src_stats = 'Control'
	EXEC UpdateZScores @AggregationName = 'Evaluation', @MeasurementName = @mname, @src = 'PersonalOnline', @src_stats = 'Control'
	SET @mid = @mid + 1
END


--add composite z-score
/*
	Methodology: Essentially a weighted average divided by the overall standard deviation
	Mathematics taken from https://stats.stackexchange.com/questions/348192/combining-z-scores-by-weighted-average-sanity-check-please
*/
DECLARE @T1_Weight decimal(5,4) = 0.2
DECLARE @ScACPL_Weight decimal(5,4) = 0.35
DECLARE @Score_Weight decimal(5,4) = 0.45

UPDATE fact.Evaluation
SET Composite_Z = (T1_Z*@T1_Weight + ScACPL_Z*@ScACPL_Weight + Score_Z*@Score_Weight)/SQRT(POWER(@T1_Weight, 2) + POWER(@ScACPL_Weight, 2) + POWER(@Score_Weight, 2))


--TODO: TBD if there's a reasonable way to do z-scores here, since the data is already aggregated there might not be one
