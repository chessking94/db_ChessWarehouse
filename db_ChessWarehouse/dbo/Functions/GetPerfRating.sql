CREATE FUNCTION [dbo].[GetPerfRating] (@AvgRating INT, @Score DECIMAL(5,4))

RETURNS INT

AS

BEGIN
	DECLARE @PerfRating INT
	DECLARE @RatingEffect INT
	DECLARE @ScoreRounded DECIMAL(3,2)
	SET @ScoreRounded = ROUND(@Score, 2)
	
	SET @RatingEffect = (SELECT RatingEffect FROM stat.PerfRatingCrossRef WHERE Score = @ScoreRounded)
	SET @PerfRating = @AvgRating + @RatingEffect

	IF @PerfRating < 0
	BEGIN
		SET @PerfRating = 0
	END

	RETURN @PerfRating
END