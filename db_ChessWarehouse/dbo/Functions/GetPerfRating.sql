CREATE FUNCTION [dbo].[GetPerfRating] (@AvgRating int, @Score decimal(5,4))
RETURNS int

AS

BEGIN

	DECLARE @PerfRating int
	DECLARE @RatingEffect int
	DECLARE @ScoreRounded decimal(3,2)
	SET @ScoreRounded = ROUND(@Score, 2)
	
	SET @RatingEffect = (SELECT RatingEffect FROM stat.PerfRatingCrossRef WHERE Score = @ScoreRounded)
	SET @PerfRating = @AvgRating + @RatingEffect

	IF @PerfRating < 0
	BEGIN
		SET @PerfRating = 0
	END

	RETURN @PerfRating
END